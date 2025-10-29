import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!

interface ConsentRequestPayload {
  policy_version?: unknown
  version?: unknown
  scopes?: unknown
  source?: unknown
  appVersion?: unknown
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

  const authorization = req.headers.get('Authorization')
  if (!authorization) {
    return new Response(
      JSON.stringify({ error: 'Missing Authorization header' }),
      { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  let body: ConsentRequestPayload = {}
  try {
    body = await req.json()
  } catch (_error) {
    return new Response(
      JSON.stringify({ error: 'Invalid request body' }),
      { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  const policyVersion =
    typeof body.policy_version === 'string'
      ? body.policy_version
      : (typeof body.version === 'string' ? (body.version as string) : undefined)
  const scopes = Array.isArray(body.scopes) ? body.scopes : undefined
  if (!policyVersion) {
    return new Response(
      JSON.stringify({ error: 'policy_version is required' }),
      { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  if (!scopes || scopes.length === 0) {
    return new Response(
      JSON.stringify({ error: 'scopes must be a non-empty array' }),
      { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: authorization
      }
    }
  })

  const { data: userResult, error: authError } = await supabase.auth.getUser()
  if (authError || !userResult?.user) {
    return new Response(
      JSON.stringify({ error: 'Unauthorized' }),
      { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  const payload = {
    user_id: userResult.user.id,
    version: policyVersion,
    scopes
  }

  const { error } = await supabase
    .from('consents')
    .insert(payload)

  if (error) {
    console.error('consents insert failed', error?.code ?? 'unknown')
    return new Response(
      JSON.stringify({ error: 'Failed to log consent' }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }

  return new Response(
    JSON.stringify({ ok: true }),
    { 
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    }
  )
})
