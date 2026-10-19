import { account, accountCookie, clearAccountCookie } from '../utils/account';
import { AccessFailure } from '../../shared/features/access/domain/access';

export default defineEventHandler(async event => {
  const url = getRequestURL(event);
  if (!['GET', 'HEAD'].includes(event.method) || url.pathname !== '/iniciar-sesion') return;
  if (!getCookie(event, accountCookie)) {
    // Older sessions are scoped to /api and can only be recovered there.
    // This marker only terminates the anonymous redirect, never authorizes access.
    if (url.searchParams.get('entry') === 'checked') return;
    return sendRedirect(event, '/api/access/entry' + url.search, 302);
  }
  try {
    const session = await account(event).access.session();
    return sendRedirect(event, session.profile.onboardingCompleted ? '/inicio' : '/bienvenida', 302);
  } catch (error) {
    if (error instanceof AccessFailure && error.kind === 'unauthenticated') {
      clearAccountCookie(event);
      return;
    }
    // Preserve the existing retry screen for backend failure, rather than
    // presenting credentials as though the user had signed out.
    return sendRedirect(event, '/inicio', 302);
  }
});
