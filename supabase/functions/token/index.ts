import { create } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const url = new URL(req.url);
  const identity = url.searchParams.get("identity")?.trim();
  if (!identity) {
    return new Response(JSON.stringify({ error: "Missing identity" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID") ?? "";
  const apiKeySid = Deno.env.get("TWILIO_API_KEY_SID") ?? "";
  const apiKeySecret = Deno.env.get("TWILIO_API_KEY_SECRET") ?? "";
  const twimlAppSid = Deno.env.get("TWILIO_TWIML_APP_SID") ?? "";

  if (!accountSid || !apiKeySid || !apiKeySecret || !twimlAppSid) {
    return new Response(JSON.stringify({ error: "Missing Twilio env vars" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: apiKeySid,
    sub: accountSid,
    nbf: now,
    exp: now + 3600,
    jti: `${apiKeySid}-${crypto.randomUUID()}`,
    grants: {
      identity,
      voice: {
        outgoing: { application_sid: twimlAppSid },
        incoming: false,
      },
    },
  };

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(apiKeySecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign", "verify"],
  );

  const token = await create(
    { alg: "HS256", typ: "JWT", cty: "twilio-fpa;v=1" },
    payload,
    key,
  );

  return new Response(
    JSON.stringify({ token, identity }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
