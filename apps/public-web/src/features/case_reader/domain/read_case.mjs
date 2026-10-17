import { validSlug, ReaderFailure } from './case.mjs';

/** @typedef {{read: (slug:string, signal?:AbortSignal)=>Promise<object>}} CaseRepository */
export class ReadCase {
  /** @param {CaseRepository} repository */
  constructor(repository) { this.repository = repository; }
  async execute(slug, signal) {
    if (!validSlug(slug)) return Object.freeze({ state: 'unavailable' });
    return this.repository.read(slug, signal);
  }
}

/** Server-only operation. The repository revalidates the link before serving bytes. */
export class ReadCasePhoto {
  constructor(repository) { this.repository = repository; }
  async execute(slug, index, signal) {
    if (!validSlug(slug) || !Number.isInteger(index) || index < 0 || index > 2) throw new ReaderFailure('not_found');
    return this.repository.photo(slug, index, signal);
  }
}
