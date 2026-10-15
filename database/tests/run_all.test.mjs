import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';

const bundle = await readFile(new URL('../run_all.sql', import.meta.url), 'utf8');
test('Publication lock timeout is local, repeatable and preserves authorization and rollback', async (t) => {
  const db = await database(t);
  await db.exec(bundle);
  const signature = 'public.publish_lost_case(uuid,uuid,integer,timestamptz,double precision,double precision,text,uuid[])';
  const describe = async () => (await db.query(`select proconfig, prosecdef,
    has_function_privilege('authenticated', oid, 'execute') as owner_can_call,
    has_function_privilege('anon', oid, 'execute') as anon_can_call
    from pg_catalog.pg_proc where oid = $1::regprocedure`, [signature])).rows[0];
  const before = await describe();
  assert.ok(before.proconfig.includes('lock_timeout=5s'));
  assert.ok(before.proconfig.includes('search_path=""'));
  assert.equal(before.prosecdef, true);
  assert.equal(before.owner_can_call, true);
  assert.equal(before.anon_can_call, false);
  const patch = await readFile(new URL('../patchs/015_patch_lost_case_lock_timeout.sql', import.meta.url), 'utf8');
  await db.exec(patch); await db.exec(patch); await db.exec(bundle);
  assert.deepEqual(await describe(), before);
  const sessionTimeout = (await db.query("select current_setting('lock_timeout') as value")).rows[0].value;
  await db.exec("set role authenticated; select set_config('request.jwt.claims', '{\"sub\":\"11111111-1111-4111-8111-111111111111\"}', false)");
  await assert.rejects(db.query('select * from public.publish_lost_case(null,null,null,null,null,null,null,null)'), /case_invalid/);
  assert.equal((await db.query("select current_setting('lock_timeout') as value")).rows[0].value, sessionTimeout);
  await db.exec('reset role');
  assert.equal((await db.query('select * from public.lost_cases')).rows.length, 0);
  assert.equal((await db.query('select * from public.case_events')).rows.length, 0);
});
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


test('Lost publication authorizes, deduplicates, protects history and exposes only approximate metadata and verified selected bytes', async (t) => {
  const db=await database(t);
  await db.exec(bundle);
  const owner='11111111-1111-4111-8111-111111111105', other='22222222-2222-4222-8222-222222222205';
  const pet='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa05', alien='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb05';
  const photo='cccccccc-cccc-4ccc-8ccc-cccccccccc05', unselected='cccccccc-cccc-4ccc-8ccc-cccccccccc06';
  const id='dddddddd-dddd-4ddd-8ddd-dddddddddd05';
  const actor=async (who,role='authenticated')=>{
    await db.exec('reset role');
    await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify(who?{sub:who}:{})]);
    await db.exec(`set role ${role}`);
  };
  await db.exec(`insert into auth.users(id) values('${owner}'),('${other}');
    insert into public.pets(id,owner_id,name,species,size,age_months,traits) values
    ('${pet}','${owner}','Luna','dog','small',12,'Blanca'),('${alien}','${other}','Sol','cat','medium',24,'Negra');`);
  const path=`${owner}/${pet}/${photo}.jpg`;
  for(const [ph,i] of [[photo,1],[unselected,2]]) {
    await db.exec(`insert into public.pet_photos(id,pet_id,owner_id,status,is_primary,processed_at,content_hash)
      values('${ph}','${pet}','${owner}','published',${i===1},now(),'${'a'.repeat(64)}');`);
    for(const [bucket,j] of [['pet-photos',1],['pet-photo-renditions',2],['pet-photo-thumbnails',3]]) {
      await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',[
        `eeeeeeee-eeee-4eee-8eee-eeeeeeeeee${i}${j}`,bucket,`${owner}/${pet}/${ph}.jpg`,{mimetype:'image/jpeg',size:1000}]);
    }
  }
  const params=[id,pet,1,'2026-10-09T14:30:00Z',-12.04641,-77.04281,'Referencia privada',[photo]];
  const publish=(p=params)=>db.query('select * from public.publish_lost_case($1,$2,$3,$4,$5,$6,$7,$8)',p);
  await actor(other);
  await assert.rejects(publish(),/case_unauthorized/);
  await actor(null,'anon');
  await assert.rejects(publish(),/permission denied/);
  assert.equal((await db.query('select * from public.read_public_lost_case($1)',[id])).rows.length,0);
  await actor(owner);
  await assert.rejects(publish([...params.slice(0,4),'NaN',...params.slice(5)]),/case_invalid/);
  await assert.rejects(publish([...params.slice(0,7),[]]),/case_invalid/);
  await assert.rejects(publish([...params.slice(0,7),[photo,photo]]),/case_invalid/);
  await assert.rejects(publish([...params.slice(0,3),'2099-01-01',...params.slice(4)]),/case_invalid/);
  await db.exec('reset role');
  await db.query('update public.pet_photos set processed_at=null where id=$1',[photo]);
  await actor(owner);
  await assert.rejects(publish(),/case_photos_unverified/);
  await db.exec('reset role');
  await db.query('update public.pet_photos set processed_at=now() where id=$1',[photo]);
  await actor(owner);
  const first=(await publish()).rows[0];
  const repeat=(await publish()).rows[0];
  assert.deepEqual(repeat,first);
  await assert.rejects(publish([id,pet,1,params[3],-12,-77,params[6],[photo]]),/case_conflict/);
  await assert.rejects(publish(['dddddddd-dddd-4ddd-8ddd-dddddddddd06',...params.slice(1)]),/case_already_active/);
  await assert.rejects(db.query('select public.archive_pet($1,2)',[pet]),/pet_active_case/);
  await assert.rejects(db.query('select public.begin_pet_deletion($1,2)',[pet]),/pet_has_case_history/);
  await assert.rejects(db.query('update public.lost_cases set latitude=0'),/permission denied/);
  assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
  await actor(other);
  assert.equal((await db.query('select * from public.lost_cases')).rows.length,0);
  await db.exec('reset role');
  await db.exec('create policy case_test_broad on public.lost_cases for all to authenticated using(true) with check(true); create policy case_storage_broad on storage.objects for all to anon,authenticated using(true) with check(true)');
  // Even broad policies cannot expose the private rows, originals or unselected photos.
  await actor(other);
  assert.equal((await db.query('select * from public.lost_cases')).rows.length,0);
  assert.equal((await db.query('select * from storage.objects')).rows.length,2);
  await actor(null,'anon');
  await db.exec('reset role');
  await db.exec("grant insert,update,delete on storage.objects to anon; insert into storage.buckets(id,name,public) values('case-test-other','case-test-other',false)");
  await actor(null,'anon');
  assert.equal((await db.query("update storage.objects set bucket_id='case-test-other' returning id")).rows.length,0);
  assert.equal((await db.query('delete from storage.objects returning id')).rows.length,0);
  const pub=(await db.query('select * from public.read_public_lost_case($1)',[id])).rows[0];
  assert.equal(pub.latitude,-12.045); assert.equal(pub.longitude,-77.045);
  for(const key of ['owner_id','pet_id','place_reference','pet_version','created_at']) assert.equal(key in pub,false);
  assert.equal(pub.photos.length,1); assert.equal(pub.photos[0].id,photo);
  assert.equal((await db.query('select * from storage.objects')).rows.length,2);
  await assert.rejects(db.query('select * from public.lost_cases'),/permission denied/);
  await db.exec('reset role');
  const before=(await db.query('select * from public.lost_cases')).rows;
  const events=(await db.query('select * from public.case_events')).rows;
  assert.equal(events.length,1);
  const patch=await readFile(new URL('../patchs/013_patch_lost_cases.sql',import.meta.url),'utf8');
  await db.exec(bundle); await db.exec(patch);
  assert.deepEqual((await db.query('select * from public.lost_cases')).rows,before);
  assert.deepEqual((await db.query('select * from public.case_events')).rows,events);
  // Future S5 transition must revoke byte access; URLs already signed have bounded lifetime.
  await db.query("update public.lost_cases set status='resolved' where id=$1",[id]);
  await actor(null,'anon');
  assert.equal((await db.query('select * from public.read_public_lost_case($1)',[id])).rows.length,0);
  assert.equal((await db.query('select * from storage.objects')).rows.length,0);
});

test('Found reports need no pet, deduplicate and keep pending photos private', async(t)=>{
  const db=await database(t);
  const patch=await readFile(new URL('../patchs/014_patch_found_cases.sql',import.meta.url),'utf8');
  const owner='11111111-1111-4111-8111-111111111140',other='22222222-2222-4222-8222-222222222240';
  const id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa40',photo='cccccccc-cccc-4ccc-8ccc-cccccccccc40',hash='a'.repeat(64);
  const path=owner+'/'+id+'/'+photo+'.jpg';
  const actor=async(who)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:who})]);await db.exec('set role authenticated');};
  await db.exec(bundle.split('-- Source: database/tables/052_found_cases.sql')[0]+'\ncommit;');
  await db.query('insert into auth.users(id) values($1),($2)',[owner,other]);
  await db.exec(patch);await db.exec(patch);
  await actor(owner);
  const prepare=()=>db.query('select public.prepare_found_case($1,$2)',[id,[photo]]);
  await assert.rejects(db.query('select public.prepare_found_case($1,$2)',[id,[photo,photo]]),/found_invalid/);
  await prepare();await prepare();
  const args=[id,'2026-10-09T12:00:00Z',-12.0464,-77.0428,'Referencia privada','dog',null,null,null,'Blanca con manchas',null,[photo]];
  const publish=(values=args)=>db.query('select * from public.publish_found_case($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)',values);
  await assert.rejects(publish(),/found_photos_unverified/);
  await assert.rejects(db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[owner,id,photo,hash]),/permission denied/);
  await actor(other);await assert.rejects(prepare(),/found_unauthorized/);await assert.rejects(publish(),/found_unauthorized/);
  assert.equal((await db.query('select id from public.found_cases')).rows.length,0);
  await db.exec('reset role; set role service_role');
  await db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[owner,id,photo,hash]);
  await assert.rejects(db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[owner,id,photo,'b'.repeat(64)]),/found_conflict/);
  await assert.rejects(db.query('select public.complete_found_case_photo($1,$2,$3,$4)',[owner,id,photo,hash]),/found_photo_incomplete/);
  await db.exec('reset role');
  for(const [bucket,objectId] of [['found-photo-renditions','dddddddd-dddd-4ddd-8ddd-dddddddddd41'],['found-photo-thumbnails','dddddddd-dddd-4ddd-8ddd-dddddddddd42']]) await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',[objectId,bucket,path,{mimetype:'image/jpeg',size:1000}]);
  await db.exec('set role service_role');await db.query('select public.complete_found_case_photo($1,$2,$3,$4)',[owner,id,photo,hash]);
  await actor(other);assert.equal((await db.query("select * from storage.objects where bucket_id like 'found-%'")).rows.length,0);
  await db.exec('reset role; set role anon');assert.equal((await db.query('select * from public.read_public_found_case($1)',[id])).rows.length,0);assert.equal((await db.query("select * from storage.objects where bucket_id like 'found-%'")).rows.length,0);
  await actor(owner);
  for(const invalid of [{2:NaN},{2:86},{3:181},{1:'2999-01-01'},{5:'other'},{9:''},{10:'home_address'},{11:[]}]) {const bad=[...args];for(const [key,val] of Object.entries(invalid))bad[+key]=val;await assert.rejects(publish(bad),/found_invalid/);}
  const published=(await publish()).rows[0];assert.equal(published.pet_id,null);assert.equal(published.status,'active');
  assert.deepEqual((await publish()).rows[0].published_at,published.published_at);
  const changed=[...args];changed[9]='Otro rasgo';await assert.rejects(publish(changed),/found_conflict/);
  await assert.rejects(db.query('select public.begin_found_case_discard($1)',[id]),/found_conflict/);
  await assert.rejects(db.query('select latitude from public.found_cases'),/permission denied/);
  await db.exec('reset role');assert.equal((await db.query('select * from public.pets')).rows.length,0);assert.equal((await db.query('select * from public.found_case_events')).rows.length,1);
  const snapshot=(await db.query('select * from public.found_cases')).rows;
  await db.exec(patch);await db.exec(bundle);assert.deepEqual((await db.query('select * from public.found_cases')).rows,snapshot.map(row=>({...row,deleted_at:null,report_kind:"legacy_found",target_lost_case_id:null,target_community_case_id:null})));
  await db.exec("create policy test_found_broad on storage.objects for all to authenticated,anon using(true) with check(true); grant insert,update,delete on storage.objects to anon;");
  await actor(other);assert.equal((await db.query("select * from storage.objects where bucket_id like 'found-%'")).rows.length,2);
  await db.exec('reset role; set role anon');
  const projection=(await db.query('select * from public.read_public_found_case($1)',[id])).rows[0];
  for(const privateKey of ['owner_id','pet_id','place_reference','created_at','photo_ids'])assert.equal(privateKey in projection,false);
  assert.notEqual(projection.latitude,args[2]);assert.equal(projection.photos.length,1);
  await assert.rejects(db.query('select id from public.found_cases'),/permission denied/);
  assert.equal((await db.query("update storage.objects set bucket_id='found-photo-thumbnails' where bucket_id='found-photo-renditions' returning id")).rows.length,0);
  assert.equal((await db.query("delete from storage.objects where bucket_id like 'found-%' returning id")).rows.length,0);
  await assert.rejects(db.query('insert into storage.objects(id,bucket_id,name) values($1,$2,$3)',['eeeeeeee-eeee-4eee-8eee-eeeeeeeeee40','found-photo-renditions','forged.jpg']),/row-level security/);
  const pending='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa41',pendingPhoto='cccccccc-cccc-4ccc-8ccc-cccccccccc41',pendingPath=owner+'/'+pending+'/'+pendingPhoto+'.jpg';
  await actor(owner);await db.query('select public.prepare_found_case($1,$2)',[pending,[pendingPhoto]]);
  await db.exec('reset role; set role service_role');await db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[owner,pending,pendingPhoto,hash]);
  await db.exec('reset role');await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',['dddddddd-dddd-4ddd-8ddd-dddddddddd43','found-photo-renditions',pendingPath,{mimetype:'image/jpeg',size:1000}]);
  await actor(other);await assert.rejects(db.query('select public.begin_found_case_discard($1)',[pending]),/found_unauthorized/);
  assert.equal((await db.query("select * from storage.objects where bucket_id like 'found-%'")).rows.length,2);
  await actor(owner);assert.equal((await db.query('select * from public.begin_found_case_discard($1)',[pending])).rows.length,1);
  await assert.rejects(db.query('select public.finish_found_case_discard($1)',[pending]),/found_photo_incomplete/);
  assert.equal((await db.query('delete from storage.objects where name=$1 returning id',[pendingPath])).rows.length,1);
  await db.query('select public.finish_found_case_discard($1)',[pending]);await db.query('select public.finish_found_case_discard($1)',[pending]);
  assert.equal((await db.query('select * from public.list_my_found_cases()')).rows.length,1);
  await assert.rejects(db.query('select public.prepare_found_case($1,$2)',[pending,[pendingPhoto]]),/found_conflict/);
  await db.exec('reset role; set role service_role');
  await assert.rejects(db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[owner,pending,pendingPhoto,hash]),/found_conflict/);
  await db.exec('reset role');
  // Simulate a late worker creating bytes after discard was confirmed. The ledger
  // keeps these private and exposes a cleanup retry only to the original reporter.
  await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',['dddddddd-dddd-4ddd-8ddd-dddddddddd44','found-photo-renditions',pendingPath,{mimetype:'image/jpeg',size:1000}]);
  await actor(other);assert.equal((await db.query('select * from public.list_my_found_cases()')).rows.length,0);
  await actor(owner);assert.equal((await db.query('select * from public.list_my_found_cases()')).rows.length,2);
  await db.query('select public.begin_found_case_discard($1)',[pending]);
  await db.query('delete from storage.objects where name=$1',[pendingPath]);
  await db.query('select public.finish_found_case_discard($1)',[pending]);
  assert.equal((await db.query('select * from public.list_my_found_cases()')).rows.length,1);
});


test('Case collections isolate owners and remove open/resolved cases idempotently without losing pet/history', async (t)=>{
 const db=await database(t); await db.exec(bundle);
 const owner='11111111-1111-4111-8111-111111111160',other='22222222-2222-4222-8222-222222222260';
 const pet='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa60',photo='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb60';
 const active='cccccccc-cccc-4ccc-8ccc-cccccccccc60',resolved='cccccccc-cccc-4ccc-8ccc-cccccccccc61';
 const found='dddddddd-dddd-4ddd-8ddd-dddddddddd60',done='dddddddd-dddd-4ddd-8ddd-dddddddddd61',draft='dddddddd-dddd-4ddd-8ddd-dddddddddd62';
 await db.exec(`insert into auth.users(id) values('${owner}'),('${other}');
 insert into public.pets(id,owner_id,name,species,size,age_months,traits,active_case_count,case_history_at)
 values('${pet}','${owner}','Luna','dog','small',12,'Blanca',1,now());
 insert into public.pet_photos(id,pet_id,owner_id,status,is_primary,content_hash,processed_at)
 values('${photo}','${pet}','${owner}','published',true,'${'a'.repeat(64)}',now());
 insert into public.lost_cases(id,owner_id,pet_id,pet_version,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids)
 values('${active}','${owner}','${pet}',1,'active',now(),-12.0464,-77.0428,'Privada',-12.045,-77.045,'Luna','dog','small',12,'Blanca',array['${photo}']::uuid[]),
 ('${resolved}','${owner}','${pet}',1,'resolved',now(),-12.0464,-77.0428,'Privada',-12.045,-77.045,'Luna','dog','small',12,'Blanca',array['${photo}']::uuid[]);
 insert into public.case_events(case_id,actor_id,event_type) values('${active}','${owner}','published');
 insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at)
 values('${found}','${owner}','active',now(),-12,-77,'Privada',-12.005,-77.005,'dog','Manchas',array['${photo}']::uuid[],now()),
 ('${done}','${owner}','resolved',now(),-12,-77,'Privada',-12.005,-77.005,'dog','Manchas',array['${photo}']::uuid[],now());
 insert into public.found_cases(id,owner_id,status,photo_ids) values('${draft}','${owner}','draft',array['${photo}']::uuid[]);`);
 const actor=async(id)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:id})]);await db.exec('set role authenticated');};
 await actor(other);
 assert.equal((await db.query('select * from public.list_my_lost_case_cards()')).rows.length,0);
 assert.equal((await db.query('select * from public.list_my_found_case_cards()')).rows.length,0);
 await assert.rejects(db.query('select public.delete_lost_case($1)',[active]),/case_unauthorized/);
 await assert.rejects(db.query('select public.delete_found_case($1)',[found]),/found_unauthorized/);
 await actor(owner);
 const cards=(await db.query('select * from public.list_my_lost_case_cards()')).rows;
 assert.equal(cards.length,2);assert.equal(cards[0].cover_path,`${owner}/${pet}/${photo}.jpg`);
 assert.equal((await db.query('select * from public.read_public_lost_case($1)',[resolved])).rows.length,1);
 assert.equal((await db.query('select * from public.read_public_found_case($1)',[done])).rows.length,1);
 await assert.rejects(db.query('select public.delete_found_case($1)',[draft]),/found_conflict/);
 await assert.rejects(db.query("update public.lost_cases set deleted_at=now()"),/permission denied/);
 for(const id of [active,resolved]) {await db.query('select public.delete_lost_case($1)',[id]);await db.query('select public.delete_lost_case($1)',[id]);}
 for(const id of [found,done]) {await db.query('select public.delete_found_case($1)',[id]);await db.query('select public.delete_found_case($1)',[id]);}
 assert.equal((await db.query('select * from public.list_my_lost_case_cards()')).rows.length,0);
 assert.deepEqual((await db.query('select id from public.list_my_found_case_cards()')).rows,[{id:draft}]);
 assert.equal((await db.query('select * from public.read_public_lost_case($1)',[active])).rows.length,0);
 assert.equal((await db.query('select * from public.read_public_found_case($1)',[found])).rows.length,0);
 await db.exec('reset role');
 const petState=(await db.query('select active_case_count,case_history_at from public.pets where id=$1',[pet])).rows[0];
 assert.equal(petState.active_case_count,0);assert.notEqual(petState.case_history_at,null);
 assert.equal((await db.query('select * from public.pet_photos')).rows.length,1);
 assert.equal((await db.query('select * from public.case_events')).rows.length,1);
 const saved=(await db.query('select id,status,deleted_at from public.lost_cases order by id')).rows;
 const migration=await readFile(new URL('../../supabase/migrations/20261010001600_case_collections.sql',import.meta.url),'utf8');
 await db.exec(migration);await db.exec(migration);await db.exec(bundle);
 assert.deepEqual((await db.query('select id,status,deleted_at from public.lost_cases order by id')).rows,saved);
 await actor(owner);
 const next='cccccccc-cccc-4ccc-8ccc-cccccccccc62';
 await db.query('select * from public.publish_lost_case($1,$2,2,now(),-12.0464,-77.0428,$3,$4)',[next,pet,'Nueva referencia',[photo]]);
 assert.deepEqual((await db.query('select id from public.list_my_lost_case_cards()')).rows,[{id:next}]);
 await db.exec('reset role');
 assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
 await db.exec('set role anon');
 await assert.rejects(db.query('select public.delete_lost_case($1)',[active]),/permission denied/);
 await assert.rejects(db.query('select public.list_my_found_case_cards()'),/permission denied/);
 assert.equal((await db.query('select * from public.read_public_lost_case($1)',[resolved])).rows.length,0);
});

test('Found publication and discard lock limits repeat without changing privileges', async (t) => {
  const db = await database(t);
  await db.exec(bundle);
  const signatures = ['prepare_found_case(uuid,uuid[])', 'prepare_found_case_photo(uuid,uuid,uuid,text)', 'complete_found_case_photo(uuid,uuid,uuid,text)', 'publish_found_case(uuid,timestamptz,double precision,double precision,text,text,text,text,text,text,text,uuid[])', 'begin_found_case_discard(uuid)', 'finish_found_case_discard(uuid)'];
  const describe = async () => (await db.query("select oid::regprocedure::text as signature, proconfig, prosecdef, has_function_privilege('authenticated',oid,'execute') as authenticated, has_function_privilege('anon',oid,'execute') as anon, has_function_privilege('service_role',oid,'execute') as service from pg_proc where oid = any($1::regprocedure[]) order by oid::regprocedure::text", [signatures.map(s => 'public.'+s)])).rows;
  const before = await describe();
  assert.equal(before.length, 6);
  for (const fn of before) {
    assert.ok(fn.proconfig.includes('lock_timeout=5s'));
    assert.ok(fn.proconfig.includes('search_path=""'));
    assert.equal(fn.prosecdef,true);
    assert.equal(fn.anon,false);
    const serverOnly = fn.signature.includes('found_case_photo');
    assert.equal(fn.authenticated,!serverOnly && !fn.signature.startsWith('publish_found_case'));
    assert.equal(fn.service,serverOnly);
  }
  const patch = await readFile(new URL('../functions/061_found_case_lock_timeout.sql',import.meta.url),'utf8');
  await db.exec(patch); await db.exec(patch); await db.exec(bundle);
  assert.deepEqual(await describe(),before);
  const timeout=(await db.query("select current_setting('lock_timeout') as value")).rows[0].value;
  await db.exec('set role authenticated');
  await assert.rejects(db.query('select public.begin_found_case_discard(null)'),/found_unauthorized/);
  assert.equal((await db.query("select current_setting('lock_timeout') as value")).rows[0].value,timeout);
  await db.exec('reset role');
  assert.equal((await db.query('select * from public.found_cases')).rows.length,0);
});


test('Recovery searches support third-party suspicions and linked notices; only search author confirms recovery', async(t)=>{
 const db=await database(t); await db.exec(bundle);
 const owner='11111111-1111-4111-8111-111111111180',reporter='22222222-2222-4222-8222-222222222280';
 const pet='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa80',petPhoto='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb80';
 const own='cccccccc-cccc-4ccc-8ccc-cccccccccc80',community='cccccccc-cccc-4ccc-8ccc-cccccccccc81';
 const notice='cccccccc-cccc-4ccc-8ccc-cccccccccc82',seen='cccccccc-cccc-4ccc-8ccc-cccccccccc83';
 const late='cccccccc-cccc-4ccc-8ccc-cccccccccc84';
 const actor=async(id,role='authenticated')=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify(id?{sub:id}:{})]);await db.exec('set role '+role);};
 await db.query('insert into auth.users(id) values($1),($2)',[owner,reporter]);
 await db.exec(`insert into public.pets(id,owner_id,name,species,species_detail,size,age_months,traits) values('${pet}','${owner}','Luna','other',repeat('X',60),'small',12,'Mancha blanca');
 insert into public.pet_photos(id,pet_id,owner_id,status,is_primary,processed_at,content_hash)
 values('${petPhoto}','${pet}','${owner}','published',true,now(),'${'a'.repeat(64)}');`);
 await actor(owner);
 await db.query('select * from public.publish_lost_case($1,$2,1,now(),-12.0464,-77.0428,$3,$4)',[own,pet,'Referencia privada',[petPhoto]]);
 const photos=new Map();let serial=0;
 async function prepare(id,author){
  serial++; const photo=`dddddddd-dddd-4ddd-8ddd-dddddddddd${String(serial).padStart(2,'0')}`;photos.set(id,photo);
  await actor(author); await db.query('select public.prepare_found_case($1,$2)',[id,[photo]]);
  await db.exec('reset role;set role service_role');
  await db.query('select public.prepare_found_case_photo($1,$2,$3,$4)',[author,id,photo,'a'.repeat(64)]);
  await db.exec('reset role');
  for(const [bucket,last] of [['found-photo-renditions','1'],['found-photo-thumbnails','2']])
   await db.query('insert into storage.objects(id,bucket_id,name,metadata) values($1,$2,$3,$4)',[
    `eeeeeeee-eeee-4eee-8eee-eeeeeeee${String(serial).padStart(3,'0')}${last}`,bucket,`${author}/${id}/${photo}.jpg`,{mimetype:'image/jpeg',size:1000}]);
  await db.exec('set role service_role');await db.query('select public.complete_found_case_photo($1,$2,$3,$4)',[author,id,photo,'a'.repeat(64)]);
  await actor(author);
 }
 async function publish(id,kind,target=null,isCommunity=false){return db.query(`select * from public.publish_recovery_report($1,$2,$3,$4,'2026-10-09',-12.0464,-77.0428,'Referencia privada','dog',null,null,null,'Foto y descripción',null,$5)`,[id,kind,target,isCommunity,[photos.get(id)]]);}
 await prepare(community,reporter); await publish(community,'possible_loss'); await publish(community,'possible_loss');
 assert.equal((await db.query('select * from public.list_open_recovery_searches()')).rows.length,2);
 const list=(await db.query('select * from public.list_open_recovery_searches()')).rows;
 assert.equal(list.some(r=>r.id===community&&r.community),true);
 for(const row of list)for(const key of ['owner_id','latitude','longitude','place_reference'])assert.equal(key in row,false);
 await prepare(notice,reporter);
 await assert.rejects(publish(notice,'sighting'),/found_invalid/);
 await assert.rejects(publish(notice,'sighting',pet),/found_invalid/);
 await publish(notice,'with_reporter',own); const noticeRow=(await publish(notice,'with_reporter',own)).rows[0]; assert.equal(noticeRow.species_detail.length,60);
 await assert.rejects(publish(notice,'sighting',own),/found_conflict/);
 await assert.rejects(db.query('select public.resolve_recovery_search($1,false)',[own]),/case_unauthorized/);
 await assert.rejects(db.query('select public.publish_found_case(null,null,null,null,null,null,null,null,null,null,null,null)'),/permission denied/);
 await assert.rejects(db.query("update public.found_cases set target_lost_case_id=null"),/permission denied/);
 await db.exec('reset role');
 assert.equal((await db.query('select status from public.lost_cases where id=$1',[own])).rows[0].status,'active');
 assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
 await actor(null,'anon');
 const notices=(await db.query('select * from public.list_recovery_observations($1,false)',[own])).rows;
 assert.equal(notices.length,1);
 const projection=Object.values(notices[0])[0];
 assert.equal(projection.report_kind,'with_reporter');assert.notEqual(projection.latitude,-12.0464);
 for(const key of ['owner_id','place_reference','target_lost_case_id'])assert.equal(key in projection,false);
 await assert.rejects(db.query('select public.resolve_recovery_search($1,false)',[own]),/permission denied/);
 await actor(owner);await db.query('select public.resolve_recovery_search($1,false)',[own]);await db.query('select public.resolve_recovery_search($1,false)',[own]);
 await db.exec('reset role');assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,0);
 assert.equal((await db.query("select * from public.case_events where case_id=$1 and event_type='resolved'",[own])).rows.length,1);
 await prepare(late,reporter);await assert.rejects(publish(late,'sighting',own),/found_target_closed/);
 await actor(null,'anon');assert.equal((await db.query('select * from public.read_recovery_report($1)',[notice])).rows.length,0);
 assert.equal((await db.query('select public.can_read_found_photo($1)',[`${reporter}/${notice}/${photos.get(notice)}.jpg`])).rows[0].can_read_found_photo,false);
 const noPhoto='cccccccc-cccc-4ccc-8ccc-cccccccccc85';
 await actor(owner);await db.query('select public.prepare_recovery_report($1,$2,$3,$4,true)',[noPhoto,[],'sighting',community]);
 const noPhotoArgs=[noPhoto,'sighting',community,true,'2026-10-09',-12,-77,'Parque','dog',null,null,null,'La vi sin poder tomar foto',null,[]];
 await db.query('select * from public.publish_recovery_report($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)',noPhotoArgs);
 await db.query('select * from public.publish_recovery_report($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)',noPhotoArgs);
 await actor(reporter);assert.equal((await db.query('select * from public.list_recovery_observations($1,true)',[community])).rows.length,1);
 await prepare(seen,owner);await publish(seen,'sighting',community,true);
 await actor(owner);await assert.rejects(db.query('select public.resolve_recovery_search($1,true)',[community]),/case_unauthorized/);
 await actor(reporter);await db.query('select public.resolve_recovery_search($1,true)',[community]);await db.query('select public.resolve_recovery_search($1,true)',[community]);
 assert.equal((await db.query('select * from public.list_open_recovery_searches()')).rows.length,0);
 await db.exec('reset role');const before=(await db.query('select id,report_kind,target_lost_case_id,target_community_case_id,status from public.found_cases order by id')).rows;
 await db.exec(bundle);await db.exec(bundle);
 assert.deepEqual((await db.query('select id,report_kind,target_lost_case_id,target_community_case_id,status from public.found_cases order by id')).rows,before);
});
