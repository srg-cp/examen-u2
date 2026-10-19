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
    new MutationObserver(() => {
      if (document.querySelector('.login-screen')) window.loginWasMounted = true;
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
    for (const url of ['/iniciar-sesion', '/login?reason=expired']) {
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
  assert.deepEqual(errors, []); await context.close();
  console.log('Session entry Chrome QA passed: SSR/SPA/legacy login never mounts, onboarding destinations, API-only cookie migration, no-JS redirect, logout/reload and no hydration/CSP errors. Fixture backend only.');
} finally { await browser.close(); await server.close(); }
