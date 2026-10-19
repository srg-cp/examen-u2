import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';
import { posix } from 'node:path';
import { RateLimit, clientAddress } from '../server/infrastructure/rate_limit.ts';
import { configuration } from '../server/infrastructure/config.ts';
import { routePolicies, routeAccess, sessionRedirect, accountDestination, assertRegisteredRoutes } from '../shared/routing/route_policy.ts';
async function sources(path) {
  const files = [];
  for (const item of await readdir(path, { withFileTypes: true })) {
    const url = new URL(item.name, path);
    if (item.isDirectory()) files.push(...await sources(new URL(`${item.name}/`, path)));
    else if (/\.(vue|ts)$/.test(item.name)) files.push([url.pathname, await readFile(url, 'utf8')]);
  }
  return files;
}

test('All pages share the global access policy; new pages cannot bypass registration', async () => {
  const pages = await sources(new URL('../app/pages/', import.meta.url));
  const patterns = pages.map(([path, source]) => {
    assert.doesNotMatch(source, /middleware\s*:/, 'Page must use the global access guard: ' + path);
    return '/' + path.split('/app/pages/')[1].replace(/\.vue$/, '').replace(/\[\.\.\.(\w+)\]/g, ':$1(.*)*').replace(/\[(\w+)\]/g, ':$1').replace(/(^|\/)index$/, '');
  });
  assert.deepEqual(patterns.sort(), Object.keys(routePolicies).sort());
  assertRegisteredRoutes(patterns);
  assert.throws(() => assertRegisteredRoutes(['/nueva-pagina']), /Define the access policy/);
  assertRegisteredRoutes(['/c/:slug()', '/:path(.*)*']);
  assert.equal(routeAccess('/moderacion/'), 'reviewer');
  assert.equal(routeAccess('/c/token'), 'public');
  assert.equal(routeAccess('/no-existe'), 'public');
  const extended = { ...routePolicies, '/mascotas/:id': 'account', '/revision/:id': 'reviewer' };
  assert.equal(routeAccess('/mascotas/123', extended), 'account');
  assert.equal(routeAccess('/revision/123/', extended), 'reviewer');
  assert.equal(routeAccess('/mascotas/123/otra', extended), 'public');
  assert.equal(sessionRedirect('reviewer', false), '/bienvenida');
  assert.equal(sessionRedirect('reviewer', true), null);
  assert.equal(sessionRedirect('public', false), null);
  for (const value of ['https://untrusted.example', '//untrusted.example', '/no-existe', '/terminos', '/moderacion?next=x']) assert.equal(accountDestination(value), null);
  assert.equal(accountDestination('/moderacion'), '/moderacion');
  const global = await readFile(new URL('../app/middleware/access.global.ts', import.meta.url), 'utf8');
  assert.match(global, /routeAccess/);
  const config = await readFile(new URL('../nuxt.config.ts', import.meta.url), 'utf8');
  assert.match(config, /pages:extend/); assert.match(config, /assertRegisteredRoutes/);
});

test('Web reveal has no legacy painted cover utility or per-screen reveal classes', async () => {
  const css = await readFile(new URL('../app/assets/main.css', import.meta.url), 'utf8');
  assert.doesNotMatch(css, /\.reveal\b|@keyframes\s+(?:cover|arrive)\s*\{/);
  for (const [path, source] of await sources(new URL('../app/features/', import.meta.url))) {
    assert.doesNotMatch(source, /class="[^"]*(?<![\w-])reveal(?![\w-])/, path);
  }
});
test('Domain and presentation boundaries keep credentials, infrastructure and SDK out of Vue/client', async () => {
  for (const [path, source] of await sources(new URL('../shared/features/', import.meta.url))) {
    if (path.includes('/domain/')) assert.doesNotMatch(source, /node:|supabase|from ['"].*(data|presentation|vue|nuxt)|fetch\(/);
    if (path.includes('/presentation/')) assert.doesNotMatch(source, /from ['"].*(\/data\/|\/server\/)|navigator\.|fetch\(/);
  }
  for (const [, source] of await sources(new URL('../app/features/', import.meta.url))) assert.doesNotMatch(source, /from ['"].*(\/data\/|\/server\/)|SUPABASE_|process\.env|\.rpc\(/);
  for (const [, source] of await sources(new URL('../app/', import.meta.url))) assert.doesNotMatch(source, /SUPABASE_SERVER_KEY|service_role|supabase_case_data_source/);
});
test('Rate limiting is bounded and trusts only explicitly configured peers', () => {
  let time = 10000; const limiter = new RateLimit({ limit: 2, maxClients: 2, windowMs: 1000, now: () => time });
  assert.equal(limiter.allow('a'), true); assert.equal(limiter.allow('a'), true); assert.equal(limiter.allow('a'), false);
  assert.equal(limiter.allow('b'), true); assert.equal(limiter.allow('c'), false); time += 1001; assert.equal(limiter.allow('c'), true);
  const req = { socket: { remoteAddress: '::ffff:127.0.0.1' }, headers: { 'x-forwarded-for': '8.8.8.8, 1.1.1.1' } };
  assert.equal(clientAddress(req, []), '127.0.0.1'); assert.equal(clientAddress(req, ['127.0.0.1']), '1.1.1.1');
});
test('Server-only configuration accepts existing Dokploy names and rejects browser keys/unsafe URLs', () => {
  assert.equal(configuration({ SUPABASE_URL: 'https://backend.example.test', SUPABASE_SERVER_KEY: 'sb_secret_test-placeholder-key' }).url, 'https://backend.example.test');
  for (const env of [{}, { SUPABASE_URL: 'http://public.example.test', SUPABASE_SERVER_KEY: 'sb_secret_test-placeholder-key' }, { SUPABASE_URL: 'https://backend.example.test', SUPABASE_SERVER_KEY: 'sb_publishable_not-server-key' }]) assert.throws(() => configuration(env));
});

test('Administrative UI remains exclusive to platform, with no Flutter administrative route', async () => {
  const mobileRouter = await readFile(new URL('../../mobile/lib/app/router.dart', import.meta.url), 'utf8');
  assert.doesNotMatch(mobileRouter, /path:\s*['"](?:admin|moderacion|moderation)(?:\/|['"])/);
  const page = await readFile(new URL('../app/pages/moderacion.vue', import.meta.url), 'utf8');
  assert.match(page, /ModerationScreen/);
  for (const [path, source] of await sources(new URL('../server/features/moderation/', import.meta.url))) {
    assert.doesNotMatch(source, /\/presentation\/|from ['"].*(?:vue|nuxt)/, path);
  }
});

test('Features collaborate through domain contracts without importing another feature data or presentation', async () => {
  for (const root of ['../shared/features/', '../app/features/', '../server/features/']) {
    for (const [path, source] of await sources(new URL(root, import.meta.url))) {
      const feature = path.match(/\/features\/([^/]+)\//)?.[1];
      for (const [, specifier] of source.matchAll(/(?:from\s+|import\s*)['"]([^'"]+)['"]/g)) {
        const target = specifier.startsWith('.') ? posix.normalize(posix.dirname(path) + '/' + specifier) : specifier;
        const dependency = target.match(/(?:^|\/)features\/([^/]+)\/(data|presentation)\//);
        if (dependency) assert.equal(dependency[1], feature, path + ' imports ' + specifier);
      }
    }
  }
  for (const [path, source] of await sources(new URL('../app/components/', import.meta.url))) {
    assert.doesNotMatch(source, /from\s+['"][^'"]*features\//, path);
  }
});
