import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { productionFixture } from '../tests/server_fixture.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const output = new URL('../../mobile/build/ui-preview/landing-vue/', import.meta.url);
await mkdir(output, { recursive: true });
let server; const results = [];
try {
  server = await productionFixture();
  for (const [name, width, height] of [['desktop', 1440, 1000], ['reference', 731, 1000], ['mobile', 390, 844], ['small', 320, 700]]) {
    const page = await browser.newPage({ viewport: { width, height }, reducedMotion: 'reduce' });
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('console', msg => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(msg.text())) errors.push(msg.text()); });
    page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${new URL(response.url()).pathname}`); });
    const response = await page.goto(server.origin, { waitUntil: 'networkidle' });
    assert.equal(response.status(), 200); assert.equal(await page.locator('h1').count(), 1);
    assert.equal(await page.locator('html').getAttribute('lang'), 'es');
    // Scroll the real page so lazy illustrations load as they do for a visitor.
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += innerHeight) {
        scrollTo(0, y); await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
      }
      scrollTo(0, 0);
      await Promise.all([...document.images].map(img => img.decode()));
    });
    const artwork = await page.locator('.art img').evaluateAll(images => images.map(img => ({ src: img.getAttribute('src'), width: img.naturalWidth, height: img.naturalHeight })));
    assert.ok(artwork.length >= 17);
    assert.ok(artwork.every(img => img.src.startsWith('/images/landing/') && img.width >= 1024 && img.height >= 800), 'Independent high-resolution artwork required everywhere');
    assert.equal(new Set(artwork.map(img => img.src)).size, 10);
    assert.equal(await page.locator('.character-label').count(), 6);
    assert.equal(await page.locator('.brand img[src="/brand.png"]').count(), 2);
    assert.equal(await page.locator('img[src*="landing-reference"]').count(), 0);
    assert.equal(await page.locator('.bandana-layer, .art svg image').count(), 0, 'Emblems must be generated into the artwork, not overlaid');
    for (const breed of ['corgi','dalmatian','tabby']) assert.ok(artwork.some(img => img.src.includes(breed)), 'Diverse pets must be present');
    assert.equal(await page.locator('.hero').evaluate(el => getComputedStyle(el).animationName), 'none');
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, `${name}: overflow`);
    const broken = await page.locator('a[href^="#"]').evaluateAll(links => links.filter(a => !document.getElementById(a.getAttribute('href').slice(1))).map(a => a.getAttribute('href')));
    assert.deepEqual(broken, []);
    assert.equal(await page.locator('[style]').count(), 0, 'Native components must preserve strict CSP');
    assert.equal(await page.locator('details').count(), 4);
    await page.screenshot({ path: fileURLToPath(new URL(`${name}.png`, output)), fullPage: true });
    const privacy = page.locator('summary').filter({ hasText: '¿Cómo se cuida la privacidad?' });
    await privacy.focus(); await page.keyboard.press('Enter');
    assert.equal(await privacy.locator('..').getAttribute('open'), ''); assert.equal(await page.locator('details[open]').count(), 1);
    await page.getByRole('navigation').getByRole('link', { name: 'Comunidad', exact: true }).click();
    await page.waitForFunction(() => location.hash === '#comunidad');
    assert.equal(await page.locator('#comunidad').evaluate(el => Math.abs(el.getBoundingClientRect().top) < 100), true);
    assert.deepEqual(errors, []); assert.equal(server.reads(), 0);
    results.push(`${name}: HTML, native FAQ/keyboard, anchors, 10 independent illustrations with printed white emblems, official logo, native cards, image decode, no overflow, no inline styles/CSP/hydration errors`);
    await page.close();
  }
  const animated = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
  await animated.goto(server.origin, { waitUntil: 'networkidle' });
  assert.equal(await animated.locator('.hero').evaluate(el => getComputedStyle(el).animationName), 'cover-reveal');
  assert.equal(await animated.locator('.hero-heading').evaluate(el => getComputedStyle(el).animationName), 'stagger-reveal');
  assert.equal(await animated.locator('.hero').evaluate(el => getComputedStyle(el).animationDuration), '0.7s');
  assert.equal(await animated.locator('.hero-heading').evaluate(el => getComputedStyle(el).animationDelay), '0.2s');
  await animated.waitForTimeout(1100);
  await animated.screenshot({ path: fileURLToPath(new URL('desktop-top.png', output)) });
  await animated.locator('.character-strip').screenshot({ path: fileURLToPath(new URL('characters.png', output)) });
  await animated.close();
  const page = await browser.newPage({ viewport: { width: 320, height: 700 }, reducedMotion: 'reduce' });
  await page.goto(server.origin, { waitUntil: 'networkidle' });
  await page.evaluate(() => {
    const nodes = [...document.querySelectorAll('h1,h2,h3,p,a,summary,.character-label,.step-number,.small-number')];
    const sizes = nodes.map(node => parseFloat(getComputedStyle(node).fontSize));
    nodes.forEach((node, index) => { node.style.fontSize = `${sizes[index] * 2}px`; });
  });
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += innerHeight) {
      scrollTo(0, y); await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    }
    scrollTo(0, 0); await Promise.all([...document.images].map(img => img.decode()));
  });
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, '200% text overflow');
  await page.screenshot({ path: fileURLToPath(new URL('small-text-200.png', output)), fullPage: true });
  await page.goto(server.origin, { waitUntil: 'networkidle' });
  await page.evaluate(() => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/c/unknown'));
  await page.getByRole('heading', { name: 'Este enlace no está disponible' }).waitFor();
  assert.equal(await page.locator('main').evaluate(el => getComputedStyle(el).maxWidth), '960px');
  assert.equal(await page.locator('.landing-page').count(), 0);
  await page.evaluate(() => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/'));
  await page.getByRole('heading', { name: /Más huellas juntas/ }).waitFor();
  assert.equal(await page.locator('.reader-shell').count(), 0);
  await page.close();
  const noJs = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 390, height: 844 } });
  const plain = await noJs.newPage(); await plain.goto(server.origin, { waitUntil: 'networkidle' });
  assert.match(await plain.locator('h1').innerText(), /Más huellas juntas/);
  const summary = plain.locator('summary').filter({ hasText: '¿Cómo se cuida la privacidad?' });
  await summary.click(); assert.equal(await summary.locator('..').getAttribute('open'), '');
  await noJs.close();
  results.push('320px/200% text, SPA landing→QR→landing style isolation, SSR and FAQ without JS passed');
  await writeFile(new URL('results.txt', output), results.join('\n') + '\n');
  console.log(results.join('\n'));
} finally { await browser.close(); if (server) await server.close(); }
