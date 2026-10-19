import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
import { routePolicies } from '../shared/routing/route_policy.ts';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture();
try {
  const context = await browser.newContext({ reducedMotion: 'reduce' });
  const errors = [];
  await context.addInitScript(() => {
    window.loginWasMounted = false;
    window.accountWasMounted = false;
    window.moderationWasMounted = false;
    new MutationObserver(() => {
      if (document.querySelector('.login-screen')) window.loginWasMounted = true;
      if (document.querySelector('.account-layout')) window.accountWasMounted = true;
      if (document.querySelector('.moderation-screen')) window.moderationWasMounted = true;
    }).observe(document, { subtree: true, childList: true });
  });
  const page = await context.newPage();
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  // A real external link keeps cross-site Fetch Metadata through HTTP redirects.
  await page.route('https://external.example/', route => route.fulfill({ contentType: 'text/html', body: '<a href="' + server.origin + '/inicio">Abrir Entre Huellas</a>' }));
  await page.goto('https://external.example/');
  await page.getByRole('link', { name: 'Abrir Entre Huellas' }).click();
  await page.waitForURL('**/iniciar-sesion'); await page.locator('.login-screen').waitFor();
  assert.equal(await page.evaluate(() => window.accountWasMounted || window.moderationWasMounted), false);
  const response = await context.request.post(server.origin + '/api/access/login', {
    headers: { Origin: server.origin }, data: { email: 'ordinario@example.test', password: 'test-fixture-password' },
  });
  assert.equal(response.status(), 200);
  const cookie = (await context.cookies()).find(c => c.name === 'eh_access');
  assert.equal(cookie.path, '/'); assert.equal(cookie.httpOnly, true);
  await page.goto(server.origin + '/');
  await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
  let releaseSession, sessionRequests = 0;
  const sessionGate = new Promise(resolve => { releaseSession = resolve; });
  await page.route('**/api/access/session', async route => { sessionRequests++; await sessionGate; await route.continue(); });
  const entryLink = page.getByRole('link', { name: 'Iniciar sesión', exact: true });
  await entryLink.click();
  await page.waitForFunction(() => document.querySelector('.header-cta')?.getAttribute('aria-busy') === 'true');
  assert.equal(new URL(page.url()).pathname, '/');
  assert.equal(await entryLink.innerText(), 'Iniciar sesión');
  assert.equal(await entryLink.getAttribute('aria-disabled'), 'true');
  assert.equal(await entryLink.evaluate(el => getComputedStyle(el, '::after').content), '""');
  await entryLink.evaluate(el => el.click());
  assert.equal(sessionRequests, 1, 'Repeated click must not start another session check');
  releaseSession(); await page.waitForURL('**/inicio');
  await page.unroute('**/api/access/session');
  for (const completed of [true, false]) {
    server.setOnboarding(ordinary, completed);
    for (const url of ['/iniciar-sesion', '/login?reason=expired', completed ? '/bienvenida' : '/inicio']) {
      await page.goto(server.origin + url);
      await page.waitForURL('**/' + (completed ? 'inicio' : 'bienvenida'));
      assert.equal(await page.evaluate(() => window.loginWasMounted), false, 'SSR must never mount login');
    }
    await page.goto(server.origin + '/');
    await page.getByRole('link', { name: 'Iniciar sesión', exact: true }).click();
    await page.waitForURL('**/' + (completed ? 'inicio' : 'bienvenida'));
    assert.equal(await page.evaluate(() => window.loginWasMounted), false, 'SPA must never mount login');
  }
  server.setOnboarding(ordinary, true);
  await context.clearCookies();
  await context.addCookies([{ ...cookie, path: '/api' }]);
  await page.goto(server.origin + '/iniciar-sesion'); await page.waitForURL('**/inicio');
  assert.equal(await page.evaluate(() => window.loginWasMounted), false, 'Legacy migration must never mount login');
  const migrated = (await context.cookies()).filter(c => c.name === 'eh_access');
  assert.equal(migrated.length, 1); assert.equal(migrated[0].path, '/');
  const noJs = await browser.newContext({ javaScriptEnabled: false });
  await noJs.addCookies(migrated);
  const noJsPage = await noJs.newPage();
  await noJsPage.goto(server.origin + '/iniciar-sesion'); assert.equal(new URL(noJsPage.url()).pathname, '/inicio');
  assert.equal(await noJsPage.locator('.login-screen').count(), 0); await noJs.close();
  await page.getByRole('button', { name: 'Cerrar sesión', exact: true }).click();
  await page.waitForURL('**/iniciar-sesion?reason=signed-out');
  await page.locator('.login-screen').waitFor();
  assert.equal((await context.cookies()).filter(c => c.name === 'eh_access').length, 0);
  await page.reload(); await page.waitForURL('**/iniciar-sesion?reason=signed-out');
  await page.locator('.login-screen').waitFor();
  const protectedPaths = Object.entries(routePolicies).filter(([, access]) => ['account', 'onboarding', 'reviewer'].includes(access)).map(([path]) => path);
  for (const path of protectedPaths) {
    await page.goto(server.origin + path);
    await page.waitForURL('**/iniciar-sesion'); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false, 'Signed-out SSR must never mount account/skeleton: ' + path);
    assert.equal(await page.evaluate(() => window.moderationWasMounted), false, 'Signed-out SSR must never mount moderation: ' + path);
    await page.reload(); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false);
    await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
    await page.evaluate(path => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push(path), path);
    await page.waitForURL('**/iniciar-sesion'); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false, 'Signed-out SPA must never mount account/skeleton: ' + path);
    assert.equal(await page.evaluate(() => window.moderationWasMounted), false, 'Signed-out SPA must never mount moderation: ' + path);
  }
  // Exercise the complete public inventory too: these routes must remain public
  // even when authentication is unavailable and cannot flash private screens.
  for (const [pattern, access] of Object.entries(routePolicies)) {
    if (access !== 'public') continue;
    const path = pattern.replace(':slug', 'a'.repeat(64)).replace(':path(.*)*', 'no-existe');
    await page.goto(server.origin + path);
    const final = path === '/login' ? '/iniciar-sesion' : path === '/terms' ? '/terminos' : path === '/privacy' ? '/privacidad' : path;
    await page.waitForURL(url => url.pathname === final && !url.searchParams.has('entry'));
    await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
    assert.equal(await page.evaluate(() => window.accountWasMounted || window.moderationWasMounted), false, 'Public SSR: ' + path);
    await page.goto(server.origin + (path === '/' ? '/terminos' : '/'));
    await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
    await page.evaluate(path => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push(path), path);
    await page.waitForURL(url => url.pathname === final);
    assert.equal(await page.evaluate(() => window.accountWasMounted || window.moderationWasMounted), false, 'Public SPA: ' + path);
  }
  // Backend failures on a legacy session must reach retry, without redirect loops.
  await context.addCookies([{ ...cookie, path: '/api' }]); server.profileFailure(true);
  await page.goto(server.origin + '/inicio');
  await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).waitFor();
  server.profileFailure(false);
  await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).click();
  await page.getByRole('heading', { name: 'Tu cuenta', exact: true }).waitFor();
  await page.goto(server.origin + '/moderacion'); await page.waitForURL('**/inicio?reason=forbidden');
  assert.equal(await page.evaluate(() => window.moderationWasMounted), false, 'Denied SSR must never mount moderation');
  await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
  await page.evaluate(() => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/moderacion'));
  await page.waitForURL('**/inicio?reason=forbidden');
  assert.equal(await page.evaluate(() => window.moderationWasMounted), false, 'Denied SPA must never mount moderation');
  assert.deepEqual(errors, []); await context.close();
  console.log('Global access Chrome QA passed: every registered page in SSR/SPA, public/QR/legal/legacy aliases, no private screen or skeleton after logout, no moderation mount without permission, authenticated login/onboarding, legacy cookies, backend retry, no-JS, no CSP/hydration errors. Fixture backend only.');
} finally { await browser.close(); await server.close(); }
