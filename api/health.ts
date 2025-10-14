export const config = { runtime: 'edge' as const };

import { buildCorsHeaders } from './utils/cors.js';
import logger from './utils/logger.js';

function createJsonResponse(
  status: number,
  body: Record<string, unknown>,
  corsHeaders: Record<string, string>,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

function createCorsResponse(status: number, corsHeaders: Record<string, string>): Response {
  return new Response(null, {
    status,
    headers: {
      ...corsHeaders,
    },
  });
}

export default function handler(req: Request): Response {
  const requestId = req.headers.get('x-request-id') ?? undefined;
  const corsHeaders = buildCorsHeaders(req.headers.get('origin'), { allowAll: true });

  if (req.method === 'OPTIONS') {
    return createCorsResponse(200, corsHeaders);
  }

  if (req.method !== 'GET') {
    logger.warn('Method not allowed on /api/health', {
      endpoint: '/api/health',
      method: req.method,
      request_id: requestId,
      status_code: 405,
    });
    return createJsonResponse(405, { error: 'Method not allowed' }, corsHeaders);
  }

  try {
    const responseBody = {
      ok: true,
      timestamp: new Date().toISOString(),
    };

    logger.info('Health check succeeded', {
      endpoint: '/api/health',
      method: 'GET',
      request_id: requestId,
      status_code: 200,
    });

    return createJsonResponse(200, responseBody, corsHeaders);
  } catch (error) {
    logger.error('Health check failed', {
      endpoint: '/api/health',
      method: 'GET',
      request_id: requestId,
      status_code: 500,
      error_type: error instanceof Error ? error.name : 'UnknownError',
    });

    return createJsonResponse(500, { error: 'Internal server error' }, corsHeaders);
  }
}
