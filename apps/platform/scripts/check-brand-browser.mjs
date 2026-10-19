import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH });
const server = await moderationFixture(), output = new URL('../../mobile/build/ui-preview/web-brand/', import.meta.url);
await mkdir(output, { recursive: true });
try {
  const context = await browser.newContext({ reducedMotion: 'reduce' }), page = await context.newPage(), errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  async function measure() {
    return page.locator('.site-header .site-brand').evaluate(e => {
      const c = getComputedStyle(e), r = e.getBoundingClientRect(), i = e.querySelector('img').getBoundingClientRect();
      return { x: r.x, y: r.y, color: c.color, font: c.fontSize, family: c.fontFamily, weight: c.fontWeight, gap: c.gap, spacing: c.letterSpacing, line: c.lineHeight, imageWidth: i.width, imageHeight: i.height };
    });
  }
  const sizes = [[1440, false], [731, false], [390, false], [320, false], [320, true]], references = new Map();
  for (const [width, enlarged] of sizes) {
    await page.setViewportSize({ width, height: 1000 }); await page.goto(server.origin);
    await page.evaluate(v => { document.documentElement.style.fontSize = v ? '200%' : '100%'; }, enlarged);
    references.set(width + ':' + enlarged, await measure());
  }
  async function compare(route) {
    for (const [width, enlarged] of sizes) {
      await page.setViewportSize({ width, height: 1000 }); await page.goto(server.origin + route);
      await page.evaluate(v => { document.documentElement.style.fontSize = v ? '200%' : '100%'; }, enlarged);
      await page.locator('.site-brand').waitFor();
      const actual = await measure(), expected = references.get(width + ':' + enlarged);
      for (const key of Object.keys(expected)) {
        if (typeof expected[key] === 'number') assert.ok(Math.abs(actual[key] - expected[key]) < 1, `${route} ${width} ${key}: ${actual[key]} != ${expected[key]}`);
        else assert.equal(actual[key], expected[key], `${route} ${width} ${key}`);
      }
      assert.equal(await page.locator('.site-brand').evaluate(e => e.getAnimations().length), 0);
      if (width === 1440) await page.screenshot({ path: fileURLToPath(new URL(route.slice(1).replaceAll('/', '-') + '.png', output)), fullPage: true });
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, route + ' ' + width + ':' + enlarged + ' overflow: ' + JSON.stringify(await page.evaluate(() => [...document.querySelectorAll('body *')].filter(e => e.getBoundingClientRect().right > innerWidth + 1).slice(-8).map(e => [e.className, e.getBoundingClientRect().width]))));
    }
  }
  for (const route of ['/iniciar-sesion', '/terminos', '/privacidad', '/c/unknown']) await compare(route);
  await page.goto(server.origin + '/iniciar-sesion');
  await page.getByLabel('Correo', { exact: true }).fill('ordinario@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
  server.setOnboarding(ordinary, false);
  await page.locator('.login-form button[type=submit]').click(); await page.waitForURL('**/bienvenida');
  await compare('/bienvenida');
  server.setOnboarding(ordinary, true); await compare('/inicio');
  await page.screenshot({ path: fileURLToPath(new URL('home-small.png', output)), fullPage: true });
  await context.clearCookies(); await page.goto(server.origin + '/iniciar-sesion');
  await page.getByLabel('Correo', { exact: true }).fill('moderador@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
  await page.locator('.login-form button[type=submit]').click(); await page.waitForURL('**/inicio');
  await compare('/moderacion');
  assert.deepEqual(errors, []);
  console.log('Brand parity passed: landing reference vs login/onboarding/home/moderation/QR/legal, position/color/type/logo dimensions, 1440/731/390/320/text200%, no overflow or CSP/hydration errors.');
} finally { await browser.close(); await server.close(); }
