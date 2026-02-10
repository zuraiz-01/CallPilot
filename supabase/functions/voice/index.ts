const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function extractTo(req: Request, body: unknown): string | null {
  const url = new URL(req.url);
  const queryTo = url.searchParams.get("To") ?? url.searchParams.get("to");
  if (queryTo && queryTo.trim().length > 0) {
    return queryTo.trim();
  }

  if (body && typeof body === "object") {
    const asRecord = body as Record<string, unknown>;
    const candidate = asRecord["To"] ?? asRecord["to"];
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim();
    }
  }

  return null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "text/plain" },
    });
  }

  let body: unknown = null;
  const contentType = req.headers.get("content-type") ?? "";
  if (contentType.includes("application/json")) {
    body = await req.json();
  } else if (contentType.includes("application/x-www-form-urlencoded")) {
    const form = await req.formData();
    body = Object.fromEntries(form.entries());
  } else if (contentType.includes("text/plain")) {
    const text = await req.text();
    try {
      body = JSON.parse(text);
    } catch (_) {
      body = { to: text };
    }
  }

  const toNumber = extractTo(req, body);
  if (!toNumber) {
    return new Response("Missing To parameter", {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "text/plain" },
    });
  }

  const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial>
    <Number>${toNumber}</Number>
  </Dial>
</Response>`;

  return new Response(twiml, {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/xml" },
  });
});
