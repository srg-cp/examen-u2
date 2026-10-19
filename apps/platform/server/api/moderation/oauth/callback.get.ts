import { moderation, clearModerationCookie } from '../../../utils/moderation';
import { moderationConfiguration } from '../../../infrastructure/moderation_session';
import { oauthCookie, oauthCookiePath, openOAuthFlow } from '../../../infrastructure/social_oauth';
import { CompleteSocialSignIn } from '../../../../shared/features/moderation/domain/social_access';
import { ModerationFailure } from '../../../../shared/features/moderation/domain/moderation';
export default defineEventHandler(async event=>{
  const cookie=getCookie(event,oauthCookie),query=getQuery(event);
  deleteCookie(event,oauthCookie,{path:oauthCookiePath,httpOnly:true,sameSite:'lax',secure:process.env.PUBLIC_WEB_ORIGIN?.startsWith('https://')===true});
  let destination='/login?reason=oauth-failed';
  try {
    const config=moderationConfiguration(process.env),flow=openOAuthFlow(cookie,query.flow,config.sessionSecret);
    if(query.error){destination=query.error==='access_denied'?'/login?reason=oauth-cancelled':destination;}
    else {
      const services=moderation(event,false);
      await new CompleteSocialSignIn(services.repository).execute(typeof query.code==='string'?query.code:'',flow.verifier);
      services.save();destination='/moderacion';
    }
  }catch(error){
    if(error instanceof ModerationFailure && error.kind==='forbidden'){clearModerationCookie(event);destination='/login?reason=forbidden';}
  }
  return sendRedirect(event,destination,303);
});
