import assert from 'node:assert/strict';
import { once } from 'node:events';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';
import { createPublicServer } from '../src/app/server.mjs';
import { configuration } from '../src/app/config.mjs';
import { RateLimit, clientAddress } from '../src/app/rate_limit.mjs';
import { ReadCase, ReadCasePhoto } from '../src/features/case_reader/domain/read_case.mjs';
import { ReaderFailure } from '../src/features/case_reader/domain/case.mjs';
import { slug, active } from './fixtures.mjs';

test('HTTP reader is anonymous, state-aware, no-store and excludes all server source/configuration', async(t) => {
  let value = active(); let reads = 0;
  const repository = { read: async () => { reads++; if (value instanceof Error) throw value; return value; }, photo: async () => { throw new ReaderFailure('not_found'); } };
  const server = await createPublicServer({ readCase: new ReadCase(repository), readPhoto: new ReadCasePhoto(repository), dist: new URL('../dist/', import.meta.url) });
  t.after(() => new Promise((resolve) => server.close(resolve))); server.listen(0, '127.0.0.1'); await once(server, 'listening');
  const origin = `http://127.0.0.1:${server.address().port}`;
  for (const path of [`/c/${slug}`, '/c/unknown', '/']) {
    const shell = await fetch(origin + path); assert.equal(shell.status, 200); assert.match(await shell.text(), /Ficha pública/); assert.equal(reads, 0);
    assert.equal(shell.headers.get('referrer-policy'), 'no-referrer'); assert.equal(shell.headers.get('cache-control'), 'no-store');
  }
  let response = await fetch(`${origin}/api/c/${slug}`); assert.equal(response.status, 200); assert.equal((await response.json()).name, 'Luna');
  value = { state: 'closed', resolution: 'resolved', closedAt: null };
  response = await fetch(`${origin}/api/c/${slug}`); assert.deepEqual(await response.json(), value);
  value = { state: 'unavailable' }; response = await fetch(`${origin}/api/c/${slug}`); assert.equal(response.status, 404);
  response = await fetch(`${origin}/api/c/not-valid`); assert.equal(response.status, 404);
  response = await fetch(`${origin}/api/c/${slug}/photos/0`); assert.equal(response.status, 404);
  value = new Error('SERVICE ROLE SDK secret'); response = await fetch(`${origin}/api/c/${slug}`); assert.equal(response.status, 503); assert.equal((await response.text()).includes('secret'), false);
  for (const path of ['/src/app/config.mjs', '/client/data/supabase_case_repository.mjs', '/.env', '/dist/manifest.json']) assert.equal((await fetch(origin + path)).status, 404);
  assert.equal((await fetch(`${origin}/api/c/${slug}`, { method: 'POST', body: 'report' })).status, 405);
  const manifest = await readFile(new URL('../dist/manifest.json', import.meta.url), 'utf8'); assert.doesNotMatch(manifest, /supabase|server|config/);
});

test('Rate limiting is bounded, expires and does not trust arbitrary forwarded headers', () => {
  let time = 10000; const limit = new RateLimit({ limit: 2, maxClients: 2, windowMs: 1000, now: () => time });
  assert.equal(limit.allow('a'), true); assert.equal(limit.allow('a'), true); assert.equal(limit.allow('a'), false);
  assert.equal(limit.allow('b'), true); assert.equal(limit.allow('c'), false); assert.equal(limit.clients.size, 2);
  time += 1001; assert.equal(limit.allow('c'), true);
  const request = { socket: { remoteAddress: '::ffff:127.0.0.1' }, headers: { 'x-forwarded-for': '8.8.8.8, 1.1.1.1' } };
  assert.equal(clientAddress(request, []), '127.0.0.1'); assert.equal(clientAddress(request, ['127.0.0.1']), '1.1.1.1');
});

test('Server configuration accepts server keys, rejects browser/unsafe URL keys and never needs secrets in the client', async () => {
  assert.equal(configuration({ SUPABASE_URL: 'https://project.example.test', SUPABASE_SERVER_KEY: 'sb_secret_server-test-key' }).port, 5173);
  for (const env of [{}, { SUPABASE_URL: 'http://public.example.test', SUPABASE_SERVER_KEY: 'sb_secret_server-test-key' }, { SUPABASE_URL: 'https://example.test', SUPABASE_SERVER_KEY: 'sb_publishable_not-secret' }]) assert.throws(() => configuration(env));
  const domain = await readdir(new URL('../src/features/case_reader/domain/', import.meta.url));
  for (const file of domain) assert.doesNotMatch(await readFile(new URL(`../src/features/case_reader/domain/${file}`, import.meta.url), 'utf8'), /node:|supabase|document\.|fetch\(/);
  for (const folder of ['data', 'presentation']) {
    for (const file of await readdir(new URL(`../src/features/case_reader/${folder}/`, import.meta.url))) {
      const source = await readFile(new URL(`../src/features/case_reader/${folder}/${file}`, import.meta.url), 'utf8');
      assert.doesNotMatch(source, /from ['"].*\/app\//);
      if (folder === 'data') assert.doesNotMatch(source, /from ['"].*\/presentation\//);
    }
  }
});
