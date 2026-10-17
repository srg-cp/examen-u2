import { ReaderFailure } from '../domain/case.mjs';

async function limitedBytes(response, limit) {
  const reader = response.body?.getReader();
  if (!reader) throw new ReaderFailure();
  const chunks = []; let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read(); if (done) break;
      size += value.length; if (size > limit) throw new ReaderFailure();
      chunks.push(value);
    }
  } finally { await reader.cancel().catch(() => {}); }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  return bytes;
}

export class SupabaseCaseDataSource {
  constructor({ url, key, fetchImpl = fetch }) {
    this.url = url; this.fetch = fetchImpl;
    this.headers = { apikey: key };
    // Secret API keys are not JWTs. Legacy self-hosted service_role JWTs are.
    if (key.startsWith('eyJ')) this.headers.Authorization = `Bearer ${key}`;
  }
  async rawCase(slug, signal) {
    try {
      const response = await this.fetch(`${this.url}/rest/v1/rpc/read_qr_case`, {
        method: 'POST', headers: { ...this.headers, 'Content-Type': 'application/json' },
        body: JSON.stringify({ p_slug: slug }), redirect: 'error', cache: 'no-store',
        signal: AbortSignal.any([AbortSignal.timeout(5000), ...(signal ? [signal] : [])]),
      });
      if (!response.ok) throw new ReaderFailure();
      return JSON.parse(new TextDecoder().decode(await limitedBytes(response, 32768)));
    } catch { throw new ReaderFailure(); }
  }
  async photo(bucket, path, signal) {
    try {
      const response = await this.fetch(`${this.url}/storage/v1/object/authenticated/${bucket}/${path}`, {
        headers: this.headers, redirect: 'error', cache: 'no-store',
        signal: AbortSignal.any([AbortSignal.timeout(5000), ...(signal ? [signal] : [])]),
      });
      if (!response.ok || response.headers.get('content-type')?.split(';')[0] !== 'image/jpeg') throw new ReaderFailure();
      const bytes = await limitedBytes(response, 2097152);
      if (bytes.length < 4 || bytes[0] !== 255 || bytes[1] !== 216 || bytes.at(-2) !== 255 || bytes.at(-1) !== 217) throw new ReaderFailure();
      return bytes;
    } catch { throw new ReaderFailure(); }
  }
}
