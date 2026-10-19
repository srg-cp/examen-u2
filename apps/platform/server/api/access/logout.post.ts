import { account, accountError, clearAccountCookie } from '../../utils/account';
import { clearModerationCookie } from '../../utils/moderation';
export default defineEventHandler(async event => {
  try { const services = account(event); clearAccountCookie(event); clearModerationCookie(event); await services.access.logout(); return { signedOut: true }; }
  catch (error) { clearAccountCookie(event); clearModerationCookie(event); return accountError(event, error); }
});

