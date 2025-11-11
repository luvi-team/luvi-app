import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!

interface ConsentPayload {
  version: string
  scopes: string[]
  user_id?: string
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

  try {
    const body: ConsentPayload = await req.json()
    
    if (!body.version || typeof body.version !== 'string') {
      return new Response(
        JSON.stringify({ error: 'Invalid version: must be string' }),
        { 
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    if (!body.scopes || !Array.isArray(body.scopes) || body.scopes.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Invalid scopes: must be non-empty array' }),
        { 
          status: 400,
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

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: authorization
        }
      }
    })

    const { data: authData, error: authError } = await supabase.auth.getUser()
    if (authError || !authData?.user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        {
          status: 401,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    if (body.user_id && body.user_id !== authData.user.id) {
      return new Response(
        JSON.stringify({ error: 'Forbidden: user mismatch' }),
        {
          status: 403,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    const { error } = await supabase
      .from('consents')
      .insert({
        user_id: authData.user.id,
        version: body.version,
        scopes: body.scopes
      })

    if (error) {
      console.error('Database error:', error)
      const status = (error as { code?: string }).code ? 403 : 400
      return new Response(
        JSON.stringify({ error: error.message }),
        { 
          status,
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

  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Invalid request body' }),
      { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }
})
