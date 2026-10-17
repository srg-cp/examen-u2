import assert from 'node:assert/strict';
import { spawn, execFile } from 'node:child_process';
import { once } from 'node:events';
import { createServer } from 'node:net';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';

test('Production bootstrap serves health and shell; container healthcheck succeeds without querying Supabase', async t => {
  const reservation = createServer(); reservation.listen(0, '127.0.0.1'); await once(reservation, 'listening');
  const port = reservation.address().port; await new Promise(resolve => reservation.close(resolve));
  const root = fileURLToPath(new URL('../', import.meta.url));
  const env = { ...process.env, HOST: '127.0.0.1', PORT: String(port), NODE_ENV: 'production',
    SUPABASE_URL: 'https://example.invalid', SUPABASE_SERVER_KEY: 'sb_secret_test-placeholder-only', TRUSTED_PROXY_IPS: '' };
  const child = spawn(process.execPath, ['src/app/main.mjs'], { cwd: root, env, stdio: ['ignore', 'pipe', 'pipe'] });
  t.after(async () => { if (child.exitCode == null) { const exited = once(child, 'exit'); child.kill(); await exited; } });
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(Error('Bootstrap did not start')), 10000);
    const done = callback => { clearTimeout(timer); callback(); };
    child.once('error', error => done(() => reject(error)));
    child.once('exit', () => done(() => reject(Error('Bootstrap exited before startup'))));
    child.stdout.once('data', () => done(resolve));
  });
  const response = await fetch(`http://127.0.0.1:${port}/health`);
  assert.equal(response.status, 200); assert.deepEqual(await response.json(), { status: 'ok' });
  assert.equal((await fetch(`http://127.0.0.1:${port}/c/unknown`)).status, 200);
  const probe = await promisify(execFile)(process.execPath, ['scripts/healthcheck.mjs'], { cwd: root, env });
  assert.equal(probe.stdout, ''); assert.equal(probe.stderr, '');
});
