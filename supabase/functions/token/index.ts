import { AccessToken } from "npm:twilio@4.21.0";

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

  const token = new AccessToken(accountSid, apiKeySid, apiKeySecret, {
    identity,
  });

  const voiceGrant = new AccessToken.VoiceGrant({
    outgoingApplicationSid: twimlAppSid,
    incomingAllow: false,
  });

  token.addGrant(voiceGrant);

  return new Response(
    JSON.stringify({ token: token.toJwt(), identity }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
