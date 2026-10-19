import { moderationBody, moderationError } from '../../../utils/moderation';
import { moderationConfiguration } from '../../../infrastructure/moderation_session';
import { authorizeSocialUrl, newOAuthFlow, sealOAuthFlow, oauthCookie, oauthCookiePath } from '../../../infrastructure/social_oauth';
export default defineEventHandler(async event => {
  try {
    const body=await moderationBody(event),config=moderationConfiguration(process.env);
    const origin=process.env.PUBLIC_WEB_ORIGIN || (import.meta.dev?getRequestURL(event).origin:'https://entrehuellas.kormind.com');
    const flow=newOAuthFlow(body.provider);
    setCookie(event,oauthCookie,sealOAuthFlow(flow,config.sessionSecret),{httpOnly:true,secure:origin.startsWith('https://'),sameSite:'lax',path:oauthCookiePath,maxAge:600});
    return {url:authorizeSocialUrl(config.url,origin,flow)};
  } catch(error){return moderationError(event,error);}
});
