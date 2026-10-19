import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture();
try {
  const context = await browser.newContext({ reducedMotion: 'reduce' });
  const errors = [];
  await context.addInitScript(() => {
    window.loginWasMounted = false;
    window.accountWasMounted = false;
    new MutationObserver(() => {
      if (document.querySelector('.login-screen')) window.loginWasMounted = true;
      if (document.querySelector('.account-layout')) window.accountWasMounted = true;
    }).observe(document, { subtree: true, childList: true });
  });
  const page = await context.newPage();
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  const response = await context.request.post(server.origin + '/api/access/login', {
    headers: { Origin: server.origin }, data: { email: 'ordinario@example.test', password: 'test-fixture-password' },
  });
  assert.equal(response.status(), 200);
  const cookie = (await context.cookies()).find(c => c.name === 'eh_access');
  assert.equal(cookie.path, '/'); assert.equal(cookie.httpOnly, true);
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
  for (const path of ['/inicio', '/bienvenida']) {
    await page.goto(server.origin + path);
    await page.waitForURL('**/iniciar-sesion'); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false, 'Signed-out SSR must never mount account/skeleton: ' + path);
    await page.reload(); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false);
    await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
    await page.evaluate(path => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push(path), path);
    await page.waitForURL('**/iniciar-sesion'); await page.locator('.login-screen').waitFor();
    assert.equal(await page.evaluate(() => window.accountWasMounted), false, 'Signed-out SPA must never mount account/skeleton: ' + path);
  }
  // Backend failures on a legacy session must reach retry, without redirect loops.
  await context.addCookies([{ ...cookie, path: '/api' }]); server.profileFailure(true);
  await page.goto(server.origin + '/inicio');
  await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).waitFor();
  server.profileFailure(false);
  await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).click();
  await page.getByRole('heading', { name: 'Tu cuenta', exact: true }).waitFor();
  assert.deepEqual(errors, []); await context.close();
  console.log('Session entry Chrome QA passed: SSR/SPA/legacy login never mounts, onboarding destinations, API-only cookie migration, no-JS redirect, logout/reload, signed-out inicio/bienvenida never mount account/skeleton, legacy backend failure retry and no hydration/CSP errors. Fixture backend only.');
} finally { await browser.close(); await server.close(); }
