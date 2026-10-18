import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';
import { RateLimit, clientAddress } from '../server/infrastructure/rate_limit.ts';
import { configuration } from '../server/infrastructure/config.ts';
async function sources(path) {
  const files = [];
  for (const item of await readdir(path, { withFileTypes: true })) {
    const url = new URL(item.name, path);
    if (item.isDirectory()) files.push(...await sources(new URL(`${item.name}/`, path)));
    else if (/\.(vue|ts)$/.test(item.name)) files.push([url.pathname, await readFile(url, 'utf8')]);
  }
  return files;
}
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
