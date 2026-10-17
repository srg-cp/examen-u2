import { isIP } from 'node:net';
const normalize = (ip = '') => ip.startsWith('::ffff:') ? ip.slice(7) : ip;

export function clientAddress(request, trustedProxies) {
  const peer = normalize(request.socket.remoteAddress);
  if (!trustedProxies.includes(peer)) return peer;
  const header = request.headers['x-forwarded-for'];
  const forwarded = typeof header === 'string' ? normalize(header.split(',').at(-1).trim()) : '';
  return isIP(forwarded) ? forwarded : peer;
}

export class RateLimit {
  constructor({ limit = 60, windowMs = 60000, maxClients = 10000, now = Date.now } = {}) {
    Object.assign(this, { limit, windowMs, maxClients, now }); this.clients = new Map(); this.lastSweep = 0;
  }
  allow(client) {
    const now = this.now();
    if (now - this.lastSweep >= 1000) {
      for (const [key, value] of this.clients) if (value.expires <= now) this.clients.delete(key);
      this.lastSweep = now;
    }
    let entry = this.clients.get(client);
    if (!entry || entry.expires <= now) {
      if (!entry && this.clients.size >= this.maxClients) return false;
      entry = { expires: now + this.windowMs, count: 0 }; this.clients.set(client, entry);
    }
    return ++entry.count <= this.limit;
  }
}
