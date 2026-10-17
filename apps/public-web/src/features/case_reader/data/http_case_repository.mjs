import { publicCase, ReaderFailure } from '../domain/case.mjs';

export class HttpCaseRepository {
  constructor(fetchImpl = (...args) => globalThis.fetch(...args)) { this.fetch = fetchImpl; }
  async read(slug, signal) {
    try {
      const response = await this.fetch(`/api/c/${slug}`, { signal, cache: 'no-store', credentials: 'omit' });
      if (response.status === 404) return publicCase({ state: 'unavailable' });
      if (!response.ok) throw new ReaderFailure(response.status === 429 ? 'rate_limited' : 'unavailable');
      return publicCase(await response.json());
    } catch (error) {
      if (signal?.aborted) throw error;
      throw error instanceof ReaderFailure ? error : new ReaderFailure();
    }
  }
}
