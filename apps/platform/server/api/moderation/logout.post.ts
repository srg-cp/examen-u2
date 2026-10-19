import { moderation,moderationError,clearModerationCookie } from '../../utils/moderation';
import { clearAccountCookie } from '../../utils/account';
export default defineEventHandler(async event=>{
  try{const services=moderation(event,false);clearModerationCookie(event);clearAccountCookie(event);await services.access.logout();return {signedOut:true};}
  catch(error){clearModerationCookie(event);clearAccountCookie(event);return moderationError(event,error);}
});
