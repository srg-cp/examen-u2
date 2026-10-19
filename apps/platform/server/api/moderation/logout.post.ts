import { moderation,moderationError,clearModerationCookie } from '../../utils/moderation';
export default defineEventHandler(async event=>{
  try{const services=moderation(event,false);clearModerationCookie(event);await services.access.logout();return {signedOut:true};}
  catch(error){clearModerationCookie(event);return moderationError(event,error);}
});
