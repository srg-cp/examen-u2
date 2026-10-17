import { createHash } from 'node:crypto';
import { publicCase, ReaderFailure } from '../domain/case.mjs';

const uuid = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
const safePath = new RegExp(`^${uuid}/${uuid}/${uuid}\\.jpg$`);
const safePhoto = (photo) => photo && ['pet-photo-renditions', 'found-photo-renditions'].includes(photo.bucket) && safePath.test(photo.path);

export class SupabaseCaseRepository {
  constructor(source) { this.source = source; }
  async read(slug, signal) {
    const raw = await this.source.rawCase(slug, signal);
    if (raw?.state === 'unavailable') return publicCase(raw);
    if (raw?.state === 'closed') return publicCase({ state: 'closed', resolution: raw.resolution, closedAt: raw.closed_at });
    if (!Array.isArray(raw?.photo_objects) || !raw.photo_objects.every(safePhoto)) throw new ReaderFailure();
    return publicCase({ state: raw.state, kind: raw.kind, name: raw.name, species: raw.species,
      speciesDetail: raw.species_detail, size: raw.size, sex: raw.sex, traits: raw.traits,
      occurredAt: raw.occurred_at, area: raw.area, photoCount: raw.photo_objects.length,
      revision: createHash('sha256').update(JSON.stringify(raw)).digest('hex') });
  }
  async photo(slug, index, signal) {
    const raw = await this.source.rawCase(slug, signal);
    const photo = raw?.state === 'active' ? raw.photo_objects?.[index] : null;
    if (!safePhoto(photo)) throw new ReaderFailure('not_found');
    const bytes = await this.source.photo(photo.bucket, photo.path, signal);
    // Closing/revocation during the Storage request must not serve a stale photo.
    const current = await this.source.rawCase(slug, signal);
    const next = current?.state === 'active' ? current.photo_objects?.[index] : null;
    if (!safePhoto(next) || next.bucket !== photo.bucket || next.path !== photo.path) throw new ReaderFailure('not_found');
    return bytes;
  }
}
