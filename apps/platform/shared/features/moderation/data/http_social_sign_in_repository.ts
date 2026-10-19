import { ModerationFailure } from '../domain/moderation.ts';
import type { SocialProvider, SocialSignInRepository } from '../domain/social_access.ts';
export class HttpSocialSignInRepository implements SocialSignInRepository {
  constructor(private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init)) {}
  async start(provider: SocialProvider): Promise<string> {
    try {
      const response = await this.fetcher('/api/moderation/oauth/start', {
        method: 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ provider }), signal: AbortSignal.timeout(20000),
      });
      if (!response.ok) { await response.body?.cancel(); throw new ModerationFailure('unavailable'); }
      const value = await response.json() as { url?: unknown };
      if (typeof value.url !== 'string') throw new ModerationFailure('unavailable');
      const url = new URL(value.url);
      if ((url.protocol !== 'https:' && !(url.protocol === 'http:' && ['127.0.0.1','localhost'].includes(url.hostname))) || url.username || url.password || url.pathname !== '/auth/v1/authorize' || url.searchParams.get('provider') !== provider) throw new ModerationFailure('unavailable');
      return url.href;
    } catch (error) { throw error instanceof ModerationFailure ? error : new ModerationFailure('unavailable'); }
  }
}
