import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { ReaderFailure } from '../features/case_reader/domain/case.mjs';
import { RateLimit, clientAddress } from './rate_limit.mjs';

const security = {
  'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY', 'Cross-Origin-Resource-Policy': 'same-origin',
  'X-Robots-Tag': 'noindex, nofollow, noarchive, nosnippet',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  'Content-Security-Policy': "default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self'; connect-src 'self'; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
};

export async function createPublicServer({ readCase, readPhoto, dist, trustedProxies = [], limiter = new RateLimit() }) {
  const files = JSON.parse(await readFile(new URL('manifest.json', dist), 'utf8'));
  const assets = new Map();
  for (const file of files) {
    const type = file.endsWith('.mjs') ? 'text/javascript; charset=utf-8' : file.endsWith('.css') ? 'text/css; charset=utf-8' : file.endsWith('.png') ? 'image/png' : 'text/html; charset=utf-8';
    assets.set(`/${file}`, { type, bytes: await readFile(new URL(file, dist)) });
  }
  let inFlight = 0;
  return createServer({ maxHeaderSize: 8192, requestTimeout: 15000, headersTimeout: 10000 }, async (req, res) => {
    for (const [key, value] of Object.entries(security)) res.setHeader(key, value);
    const send = (status, value, type = 'application/json; charset=utf-8') => {
      res.writeHead(status, { 'Content-Type': type });
      res.end(req.method === 'HEAD' ? undefined : value instanceof Uint8Array ? value : JSON.stringify(value));
    };
    if (!['GET', 'HEAD'].includes(req.method)) { res.setHeader('Allow', 'GET, HEAD'); send(405, { error: 'method_not_allowed' }); return; }
    if ((req.url?.length || 0) > 2048) { send(414, { error: 'invalid_request' }); return; }
    let path;
    try { path = new URL(req.url, 'http://internal.invalid').pathname; }
    catch { send(400, { error: 'invalid_request' }); return; }
    const asset = assets.get(path);
    if (asset) { send(200, asset.bytes, asset.type); return; }
    if (path === '/health') { send(200, { status: 'ok' }); return; }
    if (path === '/' || /^\/c\/[^/]+\/?$/.test(path)) {
      const shell = assets.get('/index.html'); send(200, shell.bytes, shell.type); return;
    }
    const route = /^\/api\/c\/([^/]+)(?:\/photos\/([0-9]+))?$/.exec(path);
    if (!route) { send(404, { state: 'unavailable' }); return; }
    if (!limiter.allow(clientAddress(req, trustedProxies))) {
      res.setHeader('Retry-After', '60'); send(429, { error: 'try_later' }); return;
    }
    if (inFlight >= 64) { send(503, { error: 'unavailable' }); return; }
    inFlight++;
    const abort = new AbortController();
    res.once('close', () => { if (!res.writableEnded) abort.abort(); });
    try {
      if (route[2] != null) {
        const bytes = await readPhoto.execute(route[1], Number(route[2]), abort.signal);
        send(200, bytes, 'image/jpeg');
      } else {
        const value = await readCase.execute(route[1], abort.signal);
        send(value.state === 'unavailable' ? 404 : 200, value);
      }
    } catch (error) {
      if (res.destroyed) return;
      send(error instanceof ReaderFailure && error.kind === 'not_found' ? 404 : 503,
        { error: error instanceof ReaderFailure && error.kind === 'not_found' ? 'not_found' : 'unavailable' });
    } finally { inFlight--; }
  });
}
