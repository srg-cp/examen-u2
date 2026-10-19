import { account, accountCookie, clearAccountCookie } from '../../utils/account';
import { AccessFailure } from '../../../shared/features/access/domain/access';

export default defineEventHandler(async event => {
  if (getCookie(event, accountCookie)) {
    try {
      const services = account(event);
      const session = await services.access.session();
      services.save();
      return sendRedirect(event, session.profile.onboardingCompleted ? '/inicio' : '/bienvenida', 302);
    } catch (error) {
      if (!(error instanceof AccessFailure) || error.kind !== 'unauthenticated') return sendRedirect(event, '/inicio', 302);
      clearAccountCookie(event);
    }
  }
  const query = getRequestURL(event).searchParams;
  query.set('entry', 'checked');
  return sendRedirect(event, '/iniciar-sesion?' + query.toString(), 302);
});
