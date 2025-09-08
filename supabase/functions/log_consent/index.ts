import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

type Scopes = string[] | Record<string, boolean>

interface ConsentPayload {
  user_id: string
  version: string
  scopes: Scopes
  granted: boolean
  timestamp: string
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      {
        status: 405,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  let body: ConsentPayload
  try {
    body = await req.json()
  } catch (_err) {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON body' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  if (!body.user_id || typeof body.user_id !== 'string') {
    return new Response(
      JSON.stringify({ error: 'Invalid user_id: must be string' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  if (!body.version || typeof body.version !== 'string') {
    return new Response(
      JSON.stringify({ error: 'Invalid version: must be string' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  const scopesIsArray = Array.isArray(body.scopes)
  const scopesIsObject = !!body.scopes && typeof body.scopes === 'object' && !scopesIsArray
  if (!scopesIsArray && !scopesIsObject) {
    return new Response(
      JSON.stringify({ error: 'Invalid scopes: must be array or object' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  if (typeof body.granted !== 'boolean') {
    return new Response(
      JSON.stringify({ error: 'Invalid granted: must be boolean' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  if (!body.timestamp || typeof body.timestamp !== 'string') {
    return new Response(
      JSON.stringify({ error: 'Invalid timestamp: must be string' }),
      {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  // MIWF: Echo validated payload for contract tests
  return new Response(
    JSON.stringify({
      message: 'Consent received',
      data: {
        user_id: body.user_id,
        version: body.version,
        scopes: body.scopes,
        granted: body.granted,
        timestamp: body.timestamp,
      }
    }),
    {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    }
  )
})
