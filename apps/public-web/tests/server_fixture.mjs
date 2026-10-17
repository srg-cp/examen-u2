import { createServer } from 'node:http';
import { once } from 'node:events';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { rawActive } from './fixtures.mjs';
export async function productionFixture(jpeg = new Uint8Array([255, 216, 255, 217])) {
  let value = rawActive(); let fail = false; let reads = 0;
  const backend = createServer(async (req, res) => {
    if (req.url === '/rest/v1/rpc/read_qr_case') {
      reads++; for await (const chunk of req) { /* Drain test request; never record token. */ }
      if (fail) { res.writeHead(503); res.end('PRIVATE SDK FAILURE'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(value)); return;
    }
    if (req.url.startsWith('/storage/v1/object/authenticated/')) { res.writeHead(200, { 'Content-Type': 'image/jpeg' }); res.end(jpeg); return; }
    res.writeHead(404); res.end();
  });
  backend.listen(0, '127.0.0.1'); await once(backend, 'listening');
  const reservation = createServer(); reservation.listen(0, '127.0.0.1'); await once(reservation, 'listening');
  const port = reservation.address().port; await new Promise(resolve => reservation.close(resolve));
  const env = { ...process.env, HOST: '127.0.0.1', PORT: String(port), NITRO_HOST: '127.0.0.1', NITRO_PORT: String(port), NODE_ENV: 'production',
    SUPABASE_URL: `http://127.0.0.1:${backend.address().port}`, SUPABASE_SERVER_KEY: 'sb_secret_test-private-canary', TRUSTED_PROXY_IPS: '' };
  const child = spawn(process.execPath, ['.output/server/index.mjs'], { cwd: fileURLToPath(new URL('../', import.meta.url)), env, stdio: ['ignore', 'pipe', 'pipe'] });
  let logs = ''; child.stderr.on('data', b => { logs += b; });
  const close = async () => {
    if (child.exitCode == null) { const exited = once(child, 'exit'); child.kill(); await exited; }
    await new Promise(resolve => backend.close(resolve));
  };
  try {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(Error('Production bootstrap timeout')), 15000);
      child.once('error', e => { clearTimeout(timer); reject(e); });
      child.once('exit', () => { clearTimeout(timer); reject(Error(`Production bootstrap failed: ${logs}`)); });
      child.stdout.once('data', () => { clearTimeout(timer); resolve(); });
    });
  } catch (error) { await close(); throw error; }
  return { origin: `http://127.0.0.1:${port}`, port, env, close, set: v => { value = v; }, fail: v => { fail = v; }, reads: () => reads, logs: () => logs };
}
