import assert from 'node:assert/strict';
import { test } from 'node:test';
import { moderationFixture, ordinary, moderator } from './moderation_fixture.mjs';
const cookieOf = r => r.headers.getSetCookie().find(c => c.startsWith('eh_access=') && !c.startsWith('eh_access=;'))?.split(';')[0];
const post = (s, path, body = {}, cookie = '', actor = ordinary, origin = s.origin) => fetch(s.origin + '/api/access/' + path, {
 method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json', Cookie: cookie, 'X-Account-Actor': actor }, body: JSON.stringify(body),
});
const login = (s, email = 'ordinario@example.test') => post(s, 'login', { email, password: 'test-fixture-password' });
test('Ordinary users enter a general session; private account data stays out of SSR and moderation remains denied', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const r = await login(s); assert.equal(r.status, 200); const cookie = cookieOf(r), session = await r.json(); assert.equal(session.actor, ordinary); assert.equal(session.profile.city, 'Lima');
 const rawCookie = r.headers.getSetCookie().find(c => c.startsWith('eh_access=') && !c.startsWith('eh_access=;'));
 assert.match(rawCookie, /HttpOnly/); assert.match(rawCookie, /SameSite=Strict/i); assert.match(rawCookie, /Path=\/;/);
 assert.doesNotMatch(JSON.stringify(session), /access_token|refresh_token|ooooooo|sb_publishable|session-secret/);
 const headers = { Cookie: cookie, 'X-Account-Actor': ordinary };
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
 const roles = await fetch(s.origin + '/api/access/management', { headers }); assert.deepEqual(await roles.json(), { canReviewReports: false });
 const denied = await fetch(s.origin + '/api/moderation/session', { headers }); assert.equal(denied.status, 403);
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
 for (const route of ['/inicio', '/bienvenida', '/iniciar-sesion']) {
  const page = await fetch(s.origin + route, { headers }); assert.equal(page.status, 200);
  assert.doesNotMatch(await page.text(), /ordinario@example.test|Usuario de prueba|PRIVATE_REPORT_REASON|ooooooo|sb_publishable_fixture/);
  assert.match(page.headers.get('cache-control'), /no-store/);
 }
 assert.equal((await post(s, 'onboarding', {}, cookie, moderator)).status, 409);
 assert.equal((await post(s, 'logout', {}, cookie)).status, 200);
 assert.equal((await fetch(s.origin + '/api/access/session')).status, 401);
});

test('Login redirects before rendering HTML, validates onboarding and never redirects to arbitrary destinations', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const cookie = cookieOf(await login(s));
 for (const completed of [true, false]) {
  s.setOnboarding(ordinary, completed);
  const r = await fetch(s.origin + '/iniciar-sesion?next=https://untrusted.example&entry=checked', { headers: { Cookie: cookie }, redirect: 'manual' });
  assert.equal(r.status, 302); assert.equal(r.headers.get('location'), completed ? '/inicio' : '/bienvenida');
  assert.match(r.headers.get('cache-control'), /no-store/);
  assert.doesNotMatch(await r.text(), /Inicia sesión|login-form|ordinario@example.test|ooooooo/);
 }
 s.profileFailure(true);
 const failure = await fetch(s.origin + '/iniciar-sesion', { headers: { Cookie: cookie }, redirect: 'manual' });
 assert.equal(failure.headers.get('location'), '/inicio');
 assert.ok(!failure.headers.getSetCookie().some(c => /Max-Age=0/.test(c)));
});

test('API-only sessions migrate without rendering login; anonymous/forged sessions reach the form without loops', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const cookie = cookieOf(await login(s));
 const bridge = await fetch(s.origin + '/iniciar-sesion?reason=expired', { redirect: 'manual' });
 assert.equal(bridge.status, 302); assert.equal(bridge.headers.get('location'), '/api/access/entry?reason=expired');
 const recovered = await fetch(s.origin + bridge.headers.get('location'), { headers: { Cookie: cookie }, redirect: 'manual' });
 assert.equal(recovered.headers.get('location'), '/inicio');
 assert.ok(recovered.headers.getSetCookie().some(c => /Path=\/api;/.test(c) && /Max-Age=0/.test(c)));
 assert.ok(recovered.headers.getSetCookie().some(c => /Path=\/;/.test(c) && !/Max-Age=0/.test(c)));
 for (const supplied of ['', 'eh_access=forged']) {
  const guest = await fetch(s.origin + '/api/access/entry?reason=expired&next=https://untrusted.example', { headers: { Cookie: supplied }, redirect: 'manual' });
  assert.equal(guest.status, 302);
  const target = new URL(guest.headers.get('location'), s.origin);
  assert.equal(target.origin, s.origin); assert.equal(target.pathname, '/iniciar-sesion');
  assert.equal(target.searchParams.get('reason'), 'expired');
  const form = await fetch(target); assert.equal(form.status, 200); assert.match(await form.text(), /Inicia sesión/);
 }
 const invalid = await fetch(s.origin + '/iniciar-sesion', { headers: { Cookie: 'eh_access=forged' }, redirect: 'manual' });
 assert.equal(invalid.status, 200); assert.match(await invalid.text(), /Inicia sesión/);
 assert.ok(invalid.headers.getSetCookie().filter(c => /Max-Age=0/.test(c)).length >= 2);
 const logout = await post(s, 'logout', {}, cookie);
 assert.ok(logout.headers.getSetCookie().some(c => /eh_access=;/.test(c) && /Path=\/;/.test(c) && /Max-Age=0/.test(c)));
 assert.ok(logout.headers.getSetCookie().some(c => /eh_access=;/.test(c) && /Path=\/api;/.test(c) && /Max-Age=0/.test(c)));
});
test('A reviewer uses the same login; each moderation request rechecks role and revocation does not remove normal access', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const r = await login(s, 'moderador@example.test'); assert.equal(r.status, 200);
 const cookie = cookieOf(r), headers = { Cookie: cookie, 'X-Account-Actor': moderator, 'X-Moderation-Actor': moderator };
 assert.deepEqual(await (await fetch(s.origin + '/api/access/management', { headers })).json(), { canReviewReports: true });
 assert.equal((await fetch(s.origin + '/api/moderation/session', { headers })).status, 200);
 s.revoke(true);
 assert.equal((await fetch(s.origin + '/api/moderation/session', { headers })).status, 403);
 assert.deepEqual(await (await fetch(s.origin + '/api/access/management', { headers })).json(), { canReviewReports: false });
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
});
test('Onboarding persists using existing account RPC, is idempotent and uses the cookie identity', async t => {
 const s = await moderationFixture(); t.after(s.close); s.setOnboarding(ordinary, false); s.setOnboarding(moderator, false);
 const r = await login(s); const cookie = cookieOf(r); assert.equal((await r.json()).profile.onboardingCompleted, false);
 assert.equal((await post(s, 'onboarding', { actor: moderator }, cookie, moderator)).status, 409);
 const done = await post(s, 'onboarding', { actor: moderator }, cookie); assert.equal(done.status, 200); assert.equal((await done.json()).profile.onboardingCompleted, true);
 assert.equal((await post(s, 'onboarding', {}, cookie)).status, 200); assert.equal(s.completions(), 1);
 const reviewer = await login(s, 'moderador@example.test'); assert.equal((await reviewer.json()).profile.onboardingCompleted, false);
});
test('Access APIs reject cross-origin/anonymous/forged cookies and failures are sanitized; missing profile does not become empty success', async t => {
 const s = await moderationFixture(); t.after(s.close);
 assert.equal((await post(s, 'login', {}, '', ordinary, 'https://untrusted.example')).status, 403);
 assert.equal((await post(s, 'onboarding')).status, 401);
 const forged = await fetch(s.origin + '/api/access/session', { headers: { Cookie: 'eh_access=forged' } }); assert.equal(forged.status, 401);
 assert.equal((await post(s, 'login', { email: 'bad', password: '' })).status, 422);
 const wrong = await post(s, 'login', { email: 'user@example.test', password: 'wrong' }); assert.equal(wrong.status, 401);
 s.profileFailure(true); const unavailable = await login(s); assert.equal(unavailable.status, 503); assert.deepEqual(await unavailable.json(), { error: 'unavailable' });
});
test('Old navigation URLs redirect permanently to Spanish routes, preserving flow parameters with a fixed internal destination', async t => {
 const s = await moderationFixture(); t.after(s.close);
 for (const [old, next] of [['login', 'iniciar-sesion'], ['terms', 'terminos'], ['privacy', 'privacidad']]) {
  const r = await fetch(s.origin + '/' + old + '?reason=expired&next=https%3A%2F%2Funtrusted.example', { redirect: 'manual' });
  assert.equal(r.status, 308); const target = new URL(r.headers.get('location'), s.origin);
  assert.equal(target.origin, s.origin); assert.equal(target.pathname, '/' + next); assert.equal(target.searchParams.get('reason'), 'expired');
  assert.equal((await fetch(s.origin + '/' + next)).status, 200);
 }
});
test('Social callbacks establish normal accounts without reviewer role and send incomplete accounts to onboarding', async t => {
 const s = await moderationFixture(); t.after(s.close); s.oauthDenied(true); s.setOnboarding(ordinary, false);
 const begin = await post(s, 'oauth/start', { provider: 'google' }); assert.equal(begin.status, 200);
 const flowCookie = begin.headers.getSetCookie().find(c => c.startsWith('eh_oauth=')).split(';')[0];
 const { url } = await begin.json(), redirect = await fetch(url, { redirect: 'manual' });
 const callback = await fetch(redirect.headers.get('location'), { redirect: 'manual', headers: { Cookie: flowCookie, 'Sec-Fetch-Site': 'cross-site' } });
 assert.equal(callback.status, 303); assert.equal(callback.headers.get('location'), '/bienvenida'); assert.ok(cookieOf(callback));
});

