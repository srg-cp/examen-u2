import { account, accountCookie, clearAccountCookie } from '../utils/account';
import { AccessFailure } from '../../shared/features/access/domain/access';

export default defineEventHandler(async event => {
  const url = getRequestURL(event);
  const login = url.pathname === '/iniciar-sesion';
  const accountPage = ['/inicio', '/bienvenida'].includes(url.pathname);
  if (!['GET', 'HEAD'].includes(event.method) || (!login && !accountPage)) return;
  if (!getCookie(event, accountCookie)) {
    // Older sessions are scoped to /api and can only be recovered there.
    // This marker only terminates the anonymous redirect, never authorizes access.
    if (login && url.searchParams.get('entry') === 'checked') return;
    // A failed legacy lookup can render the existing retry shell, never data.
    if (accountPage && url.searchParams.get('entry') === 'unavailable') return;
    return sendRedirect(event, '/api/access/entry' + url.search, 302);
  }
  try {
    const session = await account(event).access.session();
    const destination = session.profile.onboardingCompleted ? '/inicio' : '/bienvenida';
    if (url.pathname !== destination) return sendRedirect(event, destination, 302);
  } catch (error) {
    if (error instanceof AccessFailure && error.kind === 'unauthenticated') {
      clearAccountCookie(event);
      if (accountPage) return sendRedirect(event, '/iniciar-sesion?entry=checked&reason=expired', 302);
      return;
    }
    // Preserve the existing retry screen for backend failure, rather than
    // presenting credentials as though the user had signed out.
    if (login) return sendRedirect(event, '/inicio', 302);
  }
});
