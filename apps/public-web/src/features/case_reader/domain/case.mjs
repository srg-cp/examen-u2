export const validSlug = (value) => typeof value === 'string' && /^[0-9a-f]{64}$/.test(value);

export class ReaderFailure extends Error {
  constructor(kind = 'unavailable') { super(kind); this.name = 'ReaderFailure'; this.kind = kind; }
}

const text = (value, limit, optional = false) => {
  if (optional && value == null) return null;
  if (typeof value !== 'string' || [...value].length > limit) throw new ReaderFailure();
  return value;
};
const date = (value, optional = false) => {
  if (optional && value == null) return null;
  if (typeof value !== 'string' || value.length > 40 || !Number.isFinite(Date.parse(value))) throw new ReaderFailure();
  return new Date(value).toISOString();
};

// Construct an allowlisted entity, never spread an upstream/server object.
export function publicCase(value) {
  if (!value || typeof value !== 'object') throw new ReaderFailure();
  if (value.state === 'unavailable') return Object.freeze({ state: 'unavailable' });
  if (value.state === 'closed' && value.resolution === 'resolved') {
    return Object.freeze({ state: 'closed', resolution: 'resolved', closedAt: date(value.closedAt, true) });
  }
  const area = value.area;
  if (value.state !== 'active' || !['lost', 'found'].includes(value.kind) ||
      !['dog', 'cat', 'other'].includes(value.species) ||
      ![null, 'small', 'medium', 'large'].includes(value.size) ||
      ![null, 'male', 'female'].includes(value.sex) ||
      !Number.isInteger(value.photoCount) || value.photoCount < 1 || value.photoCount > 3 ||
      !/^[0-9a-f]{64}$/.test(value.revision) || !area ||
      !Number.isFinite(area.latitude) || Math.abs(area.latitude) > 85 ||
      !Number.isFinite(area.longitude) || Math.abs(area.longitude) > 180 ||
      [area.latitude, area.longitude].some((n) => Math.abs(n * 100 - Math.round(n * 100)) > 1e-7)) throw new ReaderFailure();
  return Object.freeze({ state: 'active', kind: value.kind, name: text(value.name, 80),
    species: value.species, speciesDetail: text(value.speciesDetail, 60, true), size: value.size, sex: value.sex,
    traits: text(value.traits, 200), occurredAt: date(value.occurredAt), photoCount: value.photoCount,
    revision: value.revision, area: Object.freeze({ latitude: area.latitude, longitude: area.longitude }) });
}
