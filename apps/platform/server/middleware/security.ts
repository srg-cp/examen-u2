import { randomBytes } from 'node:crypto';
import { RateLimit, clientAddress } from '../infrastructure/rate_limit';
const limiter = new RateLimit(); let inFlight = 0;
export default defineEventHandler(event => {
  const path = getRequestURL(event).pathname;
  const trusted = (process.env.TRUSTED_PROXY_IPS || '').split(',').map(v => v.trim()).filter(Boolean);
  // Internal SSR fetch inherits server context, never a visitor-supplied header.
  const peer = typeof event.context.readerPeer === 'string' ? event.context.readerPeer : clientAddress(event.node.req, trusted);
  event.context.readerPeer = peer;
  setHeaders(event, {
    'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY', 'Cross-Origin-Resource-Policy': 'same-origin',
    'X-Robots-Tag': path === '/' ? 'index, follow' : 'noindex, nofollow, noarchive, nosnippet',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  });
  const nonce = randomBytes(18).toString('base64'); event.context.cspNonce = nonce;
  if (!import.meta.dev) setHeader(event, 'Content-Security-Policy',
    `default-src 'none'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'nonce-${nonce}'; img-src 'self'; connect-src 'self'; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`);
  if (event.method !== 'GET' && event.method !== 'HEAD') {
    setHeader(event, 'Allow', 'GET, HEAD'); setResponseStatus(event, 405); return { error: 'method_not_allowed' };
  }
  if ((event.node.req.url?.length || 0) > 2048) { setResponseStatus(event, 414); return { error: 'invalid_request' }; }
  if (!path.startsWith('/api/c/')) return;
  if (!limiter.allow(peer)) {
    setHeader(event, 'Retry-After', 60); setResponseStatus(event, 429); return { error: 'try_later' };
  }
  if (inFlight >= 64) { setResponseStatus(event, 503); return { error: 'unavailable' }; }
  inFlight++; let finished = false;
  const release = () => { if (!finished) { finished = true; inFlight--; } };
  event.node.res.once('finish', release); event.node.res.once('close', release);
});
