export class ReaderViewModel {
  constructor(readCase) {
    this.readCase = readCase; this.listeners = new Set(); this.generation = 0;
    this.state = { phase: 'loading', value: null, refreshing: false, notice: null, noticeId: 0 };
  }
  subscribe(listener) { this.listeners.add(listener); listener(this.state); return () => this.listeners.delete(listener); }
  emit(state) { this.state = Object.freeze(state); for (const listener of this.listeners) listener(this.state); }
  async load(slug) {
    if (this.slug === slug && this.pending) return;
    const old = this.slug === slug ? this.state.value : null;
    this.slug = slug; this.abort?.abort(); this.abort = new AbortController();
    const generation = ++this.generation; this.pending = true;
    this.emit({ ...this.state, phase: old ? old.state : 'loading', value: old, refreshing: !!old, notice: null });
    try {
      const next = await this.readCase.execute(slug, this.abort.signal);
      if (generation !== this.generation) return;
      const value = old && JSON.stringify(old) === JSON.stringify(next) ? old : next;
      this.emit({ ...this.state, phase: value.state, value, refreshing: false, notice: null });
    } catch (error) {
      if (generation !== this.generation) return;
      this.emit({ ...this.state, phase: old ? old.state : 'error', value: old, refreshing: false,
        notice: error.kind === 'rate_limited' ? 'rate_limited' : 'unavailable', noticeId: this.state.noticeId + 1 });
    } finally { if (generation === this.generation) this.pending = false; }
  }
  dispose() { ++this.generation; this.abort?.abort(); this.listeners.clear(); }
}
