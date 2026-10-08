import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';

const bundle = await readFile(new URL('../run_all.sql', import.meta.url), 'utf8');
const migration = await readFile(new URL('../../supabase/migrations/20261007000100_auth_profiles.sql', import.meta.url), 'utf8');
const permissions = await readFile(new URL('./001_profiles_permissions.sql', import.meta.url), 'utf8');
const onboardingPermissions = await readFile(new URL('./002_onboarding_permissions.sql', import.meta.url), 'utf8');

// Local PostgreSQL engine with a minimal Auth fixture. This is not Supabase GoTrue.
async function database(t) {
  const db = await PGlite.create();
  t.after(() => db.close());
  await db.exec(`
    create role anon;
    create role authenticated;
    create schema auth;
    create table auth.users (
      id uuid primary key, aud text, role text, email text, raw_user_meta_data jsonb
    );
    create function auth.uid() returns uuid language sql stable as $$
      select (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid
    $$;
    grant usage on schema auth to authenticated;
  `);
  return db;
}

async function snapshot(db) {
  return (await db.query(`
    select id, display_name, city, created_at::text, updated_at::text
    from public.profiles order by id
  `)).rows;
}

test('Repeated run_all preserves edited profiles, timestamps, object identities and RLS', async (t) => {
  const db = await database(t);
  await db.exec(`insert into auth.users(id, raw_user_meta_data) values
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '{"full_name":"Original"}')`);
  await db.exec(bundle);
  await db.exec(`update public.profiles set display_name = 'User edited', city = 'Tacna'`);
  const before = await snapshot(db);
  const objects = () => db.query(`
    select 'trigger' as kind, oid::text as id from pg_trigger
    where tgname in ('entrehuellas_auth_user_created','profiles_set_updated_at')
    union all select 'policy', oid::text from pg_policy where polrelid = 'public.profiles'::regclass
    union all select 'function', oid::text from pg_proc
    where proname in ('handle_new_auth_user','set_profile_updated_at') order by kind,id
  `);
  const identities = (await objects()).rows;
  await db.exec(bundle);
  await db.exec(bundle);
  assert.deepEqual(await snapshot(db), before);
  assert.deepEqual((await objects()).rows, identities);
  // Exercise native role isolation and column grants after the repeated bundle.
  await db.exec(permissions);
  assert.deepEqual(await snapshot(db), before);
});

test('run_all accepts the previously applied immutable migration', async (t) => {
  const db = await database(t);
  await db.exec(migration);
  await db.exec(bundle);
  await db.exec(bundle);
  await db.exec(permissions);
});

test('An incompatible existing profiles table aborts without changing its data', async (t) => {
  const db = await database(t);
  await db.exec(`create table public.profiles(id integer primary key);
    insert into public.profiles values(42)`);
  await assert.rejects(db.exec(bundle), /incompatible structure/);
  await db.exec('rollback');
  assert.deepEqual((await db.query('select * from public.profiles')).rows, [{ id: 42 }]);
  assert.equal((await db.query("select to_regprocedure('public.handle_new_auth_user()') as name")).rows[0].name, null);
});

test('Onboarding completion is per account, repeatable and cannot be reset by clients', async (t) => {
  const db = await database(t);
  await db.exec(bundle);
  await db.exec(onboardingPermissions);
  await db.exec(`insert into auth.users(id) values('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
    set role authenticated;
    select set_config('request.jwt.claims', '{"sub":"bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb"}', false);
    select public.complete_onboarding();
    reset role;`);
  const completion = () => db.query(`select onboarding_completed_at::text as completed, updated_at::text as updated
    from public.profiles where id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'`);
  const saved = (await completion()).rows;
  assert.notEqual(saved[0].completed, null);
  await db.exec(bundle);
  assert.deepEqual((await completion()).rows, saved);
  await db.exec(onboardingPermissions);
});
