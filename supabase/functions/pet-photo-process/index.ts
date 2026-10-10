import { createClient } from "@supabase/supabase-js";
import {
  initializeProcessor,
  InvalidPhoto,
  jpegDimensions,
  processPhoto,
} from "./processor.ts";

await initializeProcessor();
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info, x-pet-id, x-photo-id",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  Response.json(body, { status, headers: cors });
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
function photoResponse(row: Record<string, unknown>) {
  return json({
    id: row.id,
    pet_id: row.pet_id,
    owner_id: row.owner_id,
    status: row.status,
    processed_at: row.processed_at,
    is_primary: row.is_primary,
  });
}

async function boundedBody(req: Request): Promise<Uint8Array> {
  if (!req.body || Number(req.headers.get("content-length") ?? 0) > 2097152) {
    throw new InvalidPhoto();
  }
  const reader = req.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.length;
      if (size > 2097152) throw new InvalidPhoto();
      chunks.push(value);
    }
  } finally {
    await reader.cancel();
    reader.releaseLock();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  return bytes;
}

function failure(error: { code?: string; message?: string }): Response {
  return json({
    error: error.message === "photo_limit" ? "photo_limit" : "photo_failed",
  }, error.code === "42501" ? 403 : error.code === "40001" ? 409 : 503);
}

// Stateless delivery: stable photo UUID + SHA256 bind all retries to the same
// bytes. Outputs are deterministic and writable only by the server.
export async function handlePhotoRequest(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const authorization = req.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }
  const pet = req.headers.get("x-pet-id") ?? "";
  const id = req.headers.get("x-photo-id") ?? "";
  if (
    !uuid.test(pet) || !uuid.test(id) ||
    req.headers.get("content-type")?.split(";")[0] !== "image/jpeg"
  ) return json({ error: "photo_invalid" }, 422);
  const url = Deno.env.get("SUPABASE_URL")!;
  const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authorization } },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
  try {
    const { data: identity, error: authError } = await userClient.auth
      .getUser();
    if (authError || !identity.user) {
      return json({ error: "unauthorized" }, 401);
    }
    const owner = identity.user.id;
    // Authorize before reading or decoding an image.
    const { data: petRow, error: petError } = await userClient.from("pets")
      .select("id").eq("id", pet).eq("owner_id", owner).is(
        "deletion_requested_at",
        null,
      ).maybeSingle();
    if (petError || !petRow) return json({ error: "unauthorized" }, 403);
    const bytes = await boundedBody(req);
    jpegDimensions(bytes);
    // Fully decode before reserving a slot, so forged JPEG headers cannot
    // exhaust the three-photo limit with files that will never be usable.
    const outputs = processPhoto(bytes);
    const hash = Array.from(
      new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)),
    ).map((v) => v.toString(16).padStart(2, "0")).join("");
    const { data: reserved, error: reserveError } = await admin.rpc(
      "prepare_pet_photo",
      { p_owner: owner, p_pet_id: pet, p_id: id, p_hash: hash },
    );
    if (reserveError) return failure(reserveError);
    const row = reserved[0];
    if (row.processed_at && row.status === "published") {
      return photoResponse(row);
    }
    const path = `${owner}/${pet}/${id}.jpg`;
    for (
      const [bucket, content] of [["pet-photo-renditions", outputs.original], [
        "pet-photo-thumbnails",
        outputs.thumbnail,
      ]] as const
    ) {
      const { error } = await admin.storage.from(bucket).upload(path, content, {
        contentType: "image/jpeg",
        upsert: true,
        cacheControl: "0",
      });
      if (error) return json({ error: "photo_failed" }, 503);
    }
    const { data: confirmed, error: confirmError } = await admin.rpc(
      "complete_pet_photo_processing",
      { p_owner: owner, p_id: id, p_hash: hash },
    );
    if (confirmError) {
      // Removal can race processing. Never make unfinished bytes readable.
      if (confirmError.code === "42501" || confirmError.code === "40001") {
        await Promise.all(
          ["pet-photo-renditions", "pet-photo-thumbnails"].map((bucket) =>
            admin.storage.from(bucket).remove([path])
          ),
        );
      }
      return failure(confirmError);
    }
    return photoResponse(confirmed[0]);
  } catch (error) {
    return error instanceof InvalidPhoto
      ? json({ error: "photo_invalid" }, 422)
      : json({ error: "photo_failed" }, 503);
  }
}

if (import.meta.main) Deno.serve(handlePhotoRequest);
