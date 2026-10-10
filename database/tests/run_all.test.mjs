import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';

const bundle = await readFile(new URL('../run_all.sql', import.meta.url), 'utf8');
test('Processed photos require server attestation, private byte paths, versioned covers and complete removal', async (t) => {
  const db = await database(t);
  const patch = await readFile(new URL('../patchs/012_patch_pet_photo_processing.sql', import.meta.url), 'utf8');
  await db.exec(bundle.split('-- Source: database/tables/044_pet_photo_processing.sql')[0]+'\ncommit;');
  const owner='11111111-1111-4111-8111-111111111130',other='22222222-2222-4222-8222-222222222230';
  const pet='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa30',alien='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb30';
  const photo='cccccccc-cccc-4ccc-8ccc-cccccccccc30',second='cccccccc-cccc-4ccc-8ccc-cccccccccc31';
  const hash='a'.repeat(64);
  await db.exec(`insert into auth.users(id) values('${owner}'),('${other}');
    insert into public.pets(id,owner_id,name,species,size,age_months,traits) values
    ('${pet}','${owner}','Luna','dog','small',12,'Blanca'),('${alien}','${other}','Sol','cat','small',12,'Negra');`);
  await db.exec(patch);
  await db.exec(patch);
  const actor=async(id)=>{
    await db.exec('reset role');
    await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:id})]);
    await db.exec('set role authenticated');
  };
  await actor(owner);
  await assert.rejects(db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[owner,pet,photo,hash]),/permission denied/);
  await assert.rejects(db.query('select public.publish_pet_photo($1)',[photo]),/permission denied/);
  await assert.rejects(db.query('select public.reserve_pet_photo($1,$2)',[photo,pet]),/permission denied/);
  await assert.rejects(db.query('select public.list_pet_photos($1)',[alien]),/photo_unauthorized/);
  await db.exec('reset role; set role service_role');
  await db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[owner,pet,photo,hash]);
  await assert.rejects(db.query('select public.complete_pet_photo_processing($1,$2,$3)',[owner,photo,hash]),/photo_incomplete/);
  await assert.rejects(db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[owner,pet,photo,'b'.repeat(64)]),/photo_conflict/);
  await assert.rejects(db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[other,alien,photo,hash]),/photo_unauthorized/);
  await db.exec('reset role');
  // Simulate Storage metadata only; actual content sanitation is tested in Deno.
  for (const [id,offset] of [[photo,0],[second,1]]) {
    await db.exec('set role service_role');
    await db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[owner,pet,id,hash]);
    await db.exec('reset role');
    for (const [bucket,index] of [['pet-photo-renditions',1],['pet-photo-thumbnails',2]]) {
      await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',[
        `dddddddd-dddd-4ddd-8ddd-dddddddddd${offset}${index}`,bucket,`${owner}/${pet}/${id}.jpg`,{mimetype:'image/jpeg',size:1000}]);
    }
    await db.exec('set role service_role');
    await db.query('select public.complete_pet_photo_processing($1,$2,$3)',[owner,id,hash]);
    await db.query('select public.complete_pet_photo_processing($1,$2,$3)',[owner,id,hash]);
    await db.exec('reset role');
  }
  await actor(owner);
  const list=()=>db.query('select * from public.list_pet_photos($1)',[pet]);
  let rows=(await list()).rows;
  assert.equal(rows.filter(row=>row.is_primary).length,1);
  assert.equal(rows[0].id,photo);
  const revision=rows[0].selection_version;
  assert.equal(revision,1);
  await db.query('select public.set_primary_pet_photo($1,$2,$3)',[pet,second,revision]);
  await db.query('select public.set_primary_pet_photo($1,$2,$3)',[pet,second,revision]);
  await assert.rejects(db.query('select public.set_primary_pet_photo($1,$2,$3)',[pet,photo,revision]),/photo_conflict/);
  await assert.rejects(db.query('select content_hash from public.pet_photos'),/permission denied/);
  assert.equal((await db.query("select * from storage.objects where bucket_id like 'pet-photo-%'")).rows.length,4);
  assert.equal((await db.query('delete from storage.objects where name=$1 returning id',[`${owner}/${pet}/${photo}.jpg`])).rows.length,0);
  // Broad permissive policies must never bypass bucket-specific restrictive guards.
  await db.exec('reset role');
  await db.exec('create policy test_broad_storage on storage.objects for all to authenticated using(true) with check(true)');
  await actor(owner);
  await assert.rejects(db.query("insert into storage.objects(id,bucket_id,name,metadata) values('eeeeeeee-eeee-4eee-8eee-eeeeeeeeee30','pet-photo-renditions',$1,'{}')",[`${owner}/${pet}/${photo}.jpg`]),/row-level security/);
  assert.equal((await db.query("update storage.objects set metadata='{}' where bucket_id='pet-photo-renditions' returning id")).rows.length,0);
  assert.equal((await db.query("select metadata from storage.objects where bucket_id='pet-photo-renditions'")).rows[0].metadata.size,1000);
  await actor(other);
  assert.equal((await db.query("select * from storage.objects where bucket_id like 'pet-photo-%'")).rows.length,0);
  await assert.rejects(db.query('select public.set_primary_pet_photo($1,$2,$3)',[pet,photo,2]),/photo_unauthorized/);
  await assert.rejects(db.query('select public.begin_pet_photo_removal($1,$2)',[photo,pet]),/photo_unauthorized/);
  await actor(owner);
  await db.query('select public.begin_pet_photo_removal($1,$2)',[second,pet]);
  await assert.rejects(db.query('select public.remove_pet_photo($1)',[second]),/photo_file_remaining/);
  assert.equal((await list()).rows.find(row=>row.is_primary).id,photo);
  await db.exec('reset role; set role service_role');
  await assert.rejects(db.query('select public.complete_pet_photo_processing($1,$2,$3)',[owner,second,hash]),/photo_conflict/);
  await actor(owner);
  await db.query('delete from storage.objects where name=$1',[`${owner}/${pet}/${second}.jpg`]);
  await db.query('select public.remove_pet_photo($1)',[second]);
  await db.query('select public.remove_pet_photo($1)',[second]);
  await db.exec('reset role; set role service_role');
  await assert.rejects(db.query('select public.prepare_pet_photo($1,$2,$3,$4)',[owner,pet,second,hash]),/photo_deleted/);
  await db.exec('reset role');
  const before=(await db.query('select * from public.pet_photos order by id')).rows;
  await db.exec(bundle);
  await db.exec(patch);
  assert.deepEqual((await db.query('select * from public.pet_photos order by id')).rows,before);
  await db.exec('set role anon');
  assert.equal((await db.query("select * from storage.objects where bucket_id like 'pet-photo-%'")).rows.length,0);
  await assert.rejects(db.query('select * from public.list_pet_photos($1)',[pet]),/permission denied/);
  await actor(owner);
  await db.query('select public.begin_pet_deletion($1,1)',[pet]);
  await assert.rejects(db.query('select public.finish_pet_deletion($1)',[pet]),/pet_files_remaining/);
  await db.query('delete from storage.objects where name=$1',[`${owner}/${pet}/${photo}.jpg`]);
  await db.query('select public.finish_pet_deletion($1)',[pet]);
  assert.equal((await db.query('select * from public.pets where id=$1',[pet])).rows.length,0);
});
test('Alert preferences isolate accounts, pause choices, validate channels/types and deduplicate versioned retries', async (t) => {
  const db = await database(t);
  const patch = await readFile(new URL('../patchs/011_patch_alert_preferences.sql', import.meta.url), 'utf8');
  const permissions = await readFile(new URL('./010_alert_preferences_permissions.sql', import.meta.url), 'utf8');
  // Incremental upgrade from the zones schema, then repeat the new patch.
  await db.exec(bundle.split('-- Source: database/tables/040_create_alert_preferences.sql')[0] + '\ncommit;');
  await db.exec(patch);
  await db.exec(patch);
  await db.exec(permissions);
  await db.exec(`
    insert into auth.users(id) values ('33333333-3333-4333-8333-333333333327');
    select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333327"}', false);
    select public.save_alert_preferences(0, true, false, true, false, false, true);
    select public.save_alert_preferences(1, false, false, true, false, false, true);
  `);
  const before = await db.query('select * from public.alert_preferences');
  await db.exec(bundle);
  await db.exec(patch);
  assert.deepEqual(await db.query('select * from public.alert_preferences'), before);
});
test('Interest zones isolate owners, guard manual bounds, stale writes and late retries after deletion', async (t) => {
  const db = await database(t);
  const patch = await readFile(new URL('../patchs/010_patch_interest_zones.sql', import.meta.url), 'utf8');
  const permissions = await readFile(new URL('./009_interest_zone_permissions.sql', import.meta.url), 'utf8');
  await db.exec(bundle);
  await db.exec(patch);
  await db.exec(patch);
  await db.exec(permissions);
  await db.exec(`
    insert into auth.users(id) values ('33333333-3333-4333-8333-333333333326');
    select set_config('request.jwt.claims', '{"sub":"33333333-3333-4333-8333-333333333326"}', false);
    select public.save_interest_zone('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb26', 0, 'Persistente', -12, -77, 1500);
    select public.save_interest_zone('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb27', 0, 'Retirada', -12, -77, 1500);
    select public.delete_interest_zone('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb27', 1);
  `);
  const before = await db.query('select * from public.interest_zones order by id');
  await db.exec(bundle);
  assert.deepEqual(await db.query('select * from public.interest_zones order by id'), before);
});
const legacyBundle = bundle.split('-- Source: database/functions/034_validate_pet_required_fields.sql')[0] + '\ncommit;';
const requiredFieldsPatch = await readFile(new URL('../patchs/009_patch_pet_required_fields.sql', import.meta.url), 'utf8');
const archivingPatch = await readFile(new URL('../patchs/008_patch_pet_archiving.sql', import.meta.url), 'utf8');
const archivingPermissions = await readFile(new URL('./008_pet_archiving_permissions.sql', import.meta.url), 'utf8');
test('Archiving restores private pets, preserves history and guards irreversible deletion with retries', async (t) => {
  const db = await database(t);
  await db.exec(legacyBundle);
  await db.exec(archivingPatch);
  await db.exec(archivingPatch);
  await db.exec(archivingPermissions);
});
const migration = await readFile(new URL('../../supabase/migrations/20261007000100_auth_profiles.sql', import.meta.url), 'utf8');
const permissions = await readFile(new URL('./001_profiles_permissions.sql', import.meta.url), 'utf8');
const onboardingPermissions = await readFile(new URL('./002_onboarding_permissions.sql', import.meta.url), 'utf8');
const profileEdits = await readFile(new URL('./003_profile_edit_permissions.sql', import.meta.url), 'utf8');
const avatarPermissions = await readFile(new URL('./004_profile_avatar_permissions.sql', import.meta.url), 'utf8');
const avatarPatch = await readFile(new URL('../patchs/004_patch_profile_avatars.sql', import.meta.url), 'utf8');
const petsPatch = await readFile(new URL('../patchs/005_patch_pets.sql', import.meta.url), 'utf8');
const galleryPatch = await readFile(new URL('../patchs/006_patch_pet_gallery.sql', import.meta.url), 'utf8');
const galleryPermissions = await readFile(new URL('./006_pet_gallery_permissions.sql', import.meta.url), 'utf8');
const deletionPatch = await readFile(new URL('../patchs/007_patch_pet_deletion.sql', import.meta.url), 'utf8');
const deletionPermissions = await readFile(new URL('./007_pet_deletion_permissions.sql', import.meta.url), 'utf8');
test('Deletion isolates owners, rejects stale versions and retires files before metadata with safe retries', async (t) => {
  const db = await database(t);
  await db.exec(legacyBundle);
  await db.exec(deletionPatch);
  await db.exec(deletionPatch);
  await db.exec(deletionPermissions);
});
test('Pet gallery is private, limited, retryable and cannot bypass ownership or metadata validation', async (t) => {
  const db = await database(t);
  assert.doesNotMatch(galleryPatch, /alter\s+table\s+storage\.objects/i);
  await db.exec(legacyBundle);
  await db.exec(galleryPatch);
  await db.exec(galleryPatch);
  await db.exec(galleryPermissions);
});
const petsPermissions = await readFile(new URL('./005_pets_permissions.sql', import.meta.url), 'utf8');
test('Pets RPCs isolate accounts, validate fields, deduplicate retries and reject stale updates', async (t) => {
  const db = await database(t);
  await db.exec(legacyBundle);
  await db.exec(petsPatch);
  await db.exec(petsPatch);
  await db.exec(galleryPatch);
  await db.exec(galleryPatch);
  await db.exec(petsPermissions);
});

// Local PostgreSQL engine with a minimal Auth fixture. This is not Supabase GoTrue.
test('Avatar bucket is private and repeated policies isolate stable paths by account', async (t) => {
  const db = await database(t);
  await db.exec(bundle);
  await db.exec(bundle);
  await db.exec(avatarPermissions);
});
test('Manual avatar patch is repeatable without altering managed storage and rejects disabled RLS', async (t) => {
  const db = await database(t);
  assert.doesNotMatch(avatarPatch, /alter\s+table\s+storage\.objects/i);
  await db.exec(avatarPatch);
  await db.exec(avatarPatch);
  await db.exec(avatarPermissions);
  await db.exec('alter table storage.objects disable row level security');
  await assert.rejects(db.exec(avatarPatch), /Storage RLS is disabled/);
  await db.exec('rollback');
});
test('Profile editing enforces server column grants, optional values, Unicode and retry invariants', async (t) => {
  const db = await database(t);
  await db.exec(bundle);
  await db.exec(profileEdits);
  await db.exec(permissions);
});

async function database(t) {
  const db = await PGlite.create();
  t.after(() => db.close());
  await db.exec(`
    create role anon;
    create role authenticated;
    create role service_role bypassrls;
    create schema auth;
    create schema storage;
    create table storage.buckets(id text primary key, name text, public boolean, file_size_limit bigint, allowed_mime_types text[]);
    create table storage.objects(id uuid primary key, bucket_id text references storage.buckets(id), name text, metadata jsonb, unique(bucket_id, name));
    alter table storage.objects enable row level security;
    grant usage on schema storage to authenticated, anon;
    grant select, insert, update, delete on storage.objects to authenticated;
    grant select on storage.objects to anon;
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


test('Required pet metadata enforces size, age and 200 Unicode scalars, preserves legacy rows and retries', async (t) => {
  const db = await database(t);
  await db.exec(legacyBundle);
  const owner = '11111111-1111-4111-8111-111111111111';
  const other = '22222222-2222-4222-8222-222222222222';
  const legacyId = 'aaaaaaaa-1111-4111-8111-111111111111';
  const petId = 'bbbbbbbb-1111-4111-8111-111111111111';
  await db.query('insert into auth.users(id) values ($1), ($2)', [owner, other]);
  await db.query("insert into public.pets(id, owner_id, name, species) values ($1,$2,'Legacy','dog')", [legacyId, owner]);
  await db.exec(requiredFieldsPatch);
  await db.exec(requiredFieldsPatch);
  let legacy = (await db.query('select age_months, traits, size from public.pets where id=$1', [legacyId])).rows[0];
  assert.deepEqual(legacy, { age_months: null, traits: null, size: null });
  await db.exec('set role authenticated');
  await db.query("select set_config('request.jwt.claims', $1, false)", [JSON.stringify({sub: owner})]);
  const create = 'select * from public.create_pet_v2($1,$2,$3,$4,$5,$6,$7,$8)';
  const base = [petId, 'Luna', 'dog', null, 0, '🐾'.repeat(200), null, 'medium'];
  for (const [index, value, message] of [
    [1, ' ', 'pet_invalid_name'], [2, null, 'pet_invalid_species'],
    [4, null, 'pet_invalid_age'], [4, -1, 'pet_invalid_age'], [4, 601, 'pet_invalid_age'],
    [5, null, 'pet_invalid_traits'], [5, '\u00a0 ', 'pet_invalid_traits'],
    [5, '🐾'.repeat(201), 'pet_invalid_traits'], [7, null, 'pet_invalid_size'],
    [7, 'huge', 'pet_invalid_size'],
  ]) {
    const args = [...base]; args[index] = value;
    await assert.rejects(db.query(create, args), new RegExp(message));
  }
  const first = (await db.query(create, base)).rows[0];
  const retry = (await db.query(create, base)).rows[0];
  assert.equal(first.version, retry.version);
  assert.equal(first.traits, '🐾'.repeat(200));
  assert.equal(first.age_months, 0);
  assert.equal(first.sex, null);
  const update = 'select * from public.update_pet_v2($1,$2,$3,$4,$5,$6,$7,$8,$9)';
  await assert.rejects(db.query(update, [petId, 1, 'Luna', 'dog', null, 0, '', null, 'medium']), /pet_invalid_traits/);
  const edited = [petId, 1, 'Luna', 'dog', 'female', 600, 'Blanca', null, 'large'];
  assert.equal((await db.query(update, edited)).rows[0].version, 2);
  assert.equal((await db.query(update, edited)).rows[0].version, 2);
  await assert.rejects(db.query(update, [petId, 1, 'Otro', 'dog', null, 1, 'Negra', null, 'small']), /pet_conflict/);
  await assert.rejects(db.query(update, [legacyId, 1, 'Legacy edit', 'dog', null, null, null, null, null]), /pet_invalid_size/);
  await db.query('select public.archive_pet($1,1)', [legacyId]);
  await db.query('select public.restore_pet($1,2)', [legacyId]);
  await db.query("select set_config('request.jwt.claims', $1, false)", [JSON.stringify({sub: other})]);
  assert.equal((await db.query('select id from public.pets')).rows.length, 0);
  await assert.rejects(db.query(update, [petId, 2, 'Otro', 'dog', null, 1, 'Negra', null, 'small']), /pet_missing|pet_unauthorized/);
  await assert.rejects(db.query(create, base), /pet_unauthorized/);
  await assert.rejects(db.query("update public.pets set traits='Bypass' where id=$1", [petId]), /permission denied/);
  await db.exec('set role anon');
  await assert.rejects(db.query(create, base), /permission denied/);
  await db.exec('reset role');
  // The latest increment adds a server-only photo revision, without changing
  // the legacy metadata. Compare the same projection across the upgrade.
  const snapshotQuery = "select to_jsonb(p)-'photo_selection_version' as pet from public.pets p order by id";
  const snapshot = (await db.query(snapshotQuery)).rows;
  await db.exec(bundle);
  assert.deepEqual((await db.query(snapshotQuery)).rows, snapshot);
  await db.exec('set role authenticated');
  await db.query("select set_config('request.jwt.claims', $1, false)", [JSON.stringify({sub: owner})]);
  await db.query('select public.begin_pet_deletion($1,3)', [legacyId]);
  await db.query('select public.finish_pet_deletion($1)', [legacyId]);
  assert.equal((await db.query('select id from public.pets where id=$1', [legacyId])).rows.length, 0);
});
