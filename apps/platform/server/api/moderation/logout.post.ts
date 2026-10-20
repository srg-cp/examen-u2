import { moderation,clearModerationCookie } from '../../utils/moderation';
import { clearAccountCookie } from '../../utils/account';
export default defineEventHandler(event=>{
  clearModerationCookie(event);clearAccountCookie(event);
  try {
    const services=moderation(event,false);
    event.waitUntil(services.access.logout().catch(()=>{console.warn('[moderation] Remote sign-out did not complete.');}));
  } catch { console.warn('[moderation] Remote sign-out could not be scheduled.'); }
  return {signedOut:true};
});
