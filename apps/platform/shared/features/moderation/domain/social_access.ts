import { ModerationFailure } from './moderation.ts';
import type { ReviewerSession } from './moderation.ts';
export type SocialProvider = 'google' | 'facebook';
export function socialProvider(value: unknown): SocialProvider {
  if (value !== 'google' && value !== 'facebook') throw new ModerationFailure('invalid');
  return value;
}
export interface SocialSignInRepository { start(provider: SocialProvider): Promise<string>; }
export class StartSocialSignIn {
  constructor(private readonly repository: SocialSignInRepository) {}
  execute(provider: SocialProvider) { return this.repository.start(socialProvider(provider)); }
}
export interface SocialCodeRepository { exchange(code: string, verifier: string): Promise<ReviewerSession>; }
export class CompleteSocialSignIn {
  constructor(private readonly repository: SocialCodeRepository) {}
  execute(code: string, verifier: string) {
    if (!code || code.length > 2048 || !/^[A-Za-z0-9_-]{43,128}$/.test(verifier)) throw new ModerationFailure('unauthenticated');
    return this.repository.exchange(code, verifier);
  }
}
