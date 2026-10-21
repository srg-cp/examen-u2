import { RecoveryFailure } from '../domain/recovery.ts';
import type { ExploreCases, ReadMyPets, SaveMyPet, AddPetPhoto, ReadOpenSearches, PublishRecoveryReport, ReadReportDraft, SaveReportDraft, ClearReportDraft, LocalReportDraft, CaseCard, Pet, PetDraft, ReportDraft, ReportPhoto, ReportReceipt, ExploreQuery } from '../domain/recovery.ts';
type State = Readonly<{ loading: boolean; refreshing: boolean; busy: boolean; items: readonly CaseCard[]; pets: readonly Pet[]; targets: readonly CaseCard[]; cursor: string | null; failure: RecoveryFailure | null; notice: number; receipt: ReportReceipt | null }>;
export class RecoveryViewModel {
  state: State = { loading: true, refreshing: false, busy: false, items: [], pets: [], targets: [], cursor: null, failure: null, notice: 0, receipt: null };
  private listeners = new Set<(state: State) => void>(); private generation = 0; private disposed = false;
  constructor(private readonly explore: ExploreCases, private readonly readPets: ReadMyPets, private readonly save: SaveMyPet, private readonly addPhoto: AddPetPhoto, private readonly searches: ReadOpenSearches, private readonly publish: PublishRecoveryReport, private readonly readDraft:ReadReportDraft, private readonly saveDraft:SaveReportDraft, private readonly clearDraft:ClearReportDraft) {}
  subscribe(listener: (state: State) => void) { this.listeners.add(listener); return () => { this.listeners.delete(listener); }; }
  private update(change: Partial<State>) { if (this.disposed) return; this.state = { ...this.state, ...change }; for (const listener of this.listeners) listener(this.state); }
  private fail(e: unknown) { this.update({ failure: e instanceof RecoveryFailure ? e : new RecoveryFailure('unavailable'), notice: this.state.notice + 1 }); }
  async load(section: 'explore' | 'pets' | 'report', query: ExploreQuery = { kind: 'all', species: 'all', status: 'active' }, more = false) {
    if (this.state.busy || this.state.refreshing) return;
    const generation = ++this.generation;
    this.update({ refreshing: !this.state.loading, failure: null });
    try {
      if (section === 'explore') { const page = await this.explore.execute(query, more ? this.state.cursor : null); if (generation === this.generation) this.update({ items: more ? [...this.state.items, ...page.items.filter(p => !this.state.items.some(i => i.id === p.id && i.source === p.source))] : page.items, cursor: page.cursor }); }
      else { const pets = await this.readPets.execute(); const targets = section === 'report' ? await this.searches.execute() : []; if (generation === this.generation) this.update({ pets, targets }); }
    } catch (e) { if (generation === this.generation) this.fail(e); }
    finally { if (generation === this.generation) this.update({ loading: false, refreshing: false }); }
  }
  async savePet(draft: PetDraft) {
    if (this.state.busy) return null; this.update({ busy: true, failure: null });
    try { const pet = await this.save.execute(draft); this.update({ pets: [pet, ...this.state.pets.filter(p => p.id !== pet.id)] }); return pet; }
    catch (e) { this.fail(e); return null; } finally { this.update({ busy: false }); }
  }
  async uploadPetPhoto(pet: string, photo: ReportPhoto) {
    if (this.state.busy) return false; this.update({ busy: true, failure: null });
    try { await this.addPhoto.execute(pet, photo); const pets = await this.readPets.execute(); this.update({ pets }); return true; }
    catch (e) { this.fail(e); return false; } finally { this.update({ busy: false }); }
  }
  async send(draft: ReportDraft, photos: readonly ReportPhoto[]) {
    if (this.state.busy || this.state.receipt) return;
    this.update({ busy: true, failure: null });
    try { const receipt = await this.publish.execute(draft, photos); this.update({ receipt }); try { await this.clearDraft.execute(); } catch { /* Published receipt remains authoritative; stale draft can retry the same ID. */ } }
    catch (e) { this.fail(e); } finally { this.update({ busy: false }); }
  }
  async restoreDraft() { try { return await this.readDraft.execute(); } catch(e) { this.fail(e); return null; } }
  async remember(value:LocalReportDraft) { try { await this.saveDraft.execute(value); return true; } catch(e) { this.fail(e); return false; } }
  dispose() { this.disposed = true; this.generation++; this.listeners.clear(); this.state = { ...this.state, pets: [], items: [], targets: [], receipt: null }; }
}
