import { jest } from '@jest/globals';
import handler from '../health.js';
import logger from '../utils/logger.js';

const ISO_8601_REGEX =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;

const mockRequest = (method: string, headers?: HeadersInit): Request => {
  return new Request('http://localhost/api/health', {
    method,
    headers,
  });
};

const parseResponse = async (
  response: Response,
): Promise<{ status: number; body: unknown; headers: Headers }> => {
  const contentType = response.headers.get('content-type');
  let body: unknown = null;

  if (contentType?.includes('application/json')) {
    body = await response.json();
  }

  return {
    status: response.status,
    body,
    headers: response.headers,
  };
};

describe('health endpoint', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('returns 200 OK with correct body', async () => {
    const request = mockRequest('GET', { 'X-Request-ID': 'req-123' });
    const response = await handler(request);
    const parsed = await parseResponse(response);

    expect(parsed.status).toBe(200);
    expect(parsed.headers.get('content-type')).toBe('application/json');
    expect(parsed.body).toEqual(
      expect.objectContaining({
        ok: true,
        timestamp: expect.any(String),
      }),
    );

    const { timestamp } = parsed.body as { timestamp: string };
    expect(timestamp).toMatch(ISO_8601_REGEX);
  });

  it('returns 405 for non-GET methods', async () => {
    const warnSpy = jest.spyOn(logger, 'warn').mockImplementation(() => undefined);
    const request = mockRequest('POST');
    const response = await handler(request);
    const parsed = await parseResponse(response);

    expect(parsed.status).toBe(405);
    expect(parsed.body).toEqual({ error: 'Method not allowed' });
    expect(warnSpy).toHaveBeenCalledTimes(1);
  });

  it('handles OPTIONS preflight requests', async () => {
    const request = mockRequest('OPTIONS');
    const response = await handler(request);

    expect(response.status).toBe(200);
    expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
    expect(response.headers.get('Access-Control-Allow-Methods')).toBe('GET, POST, OPTIONS');
  });

  it('returns 500 on internal error and logs failure', async () => {
    jest.spyOn(logger, 'error').mockImplementation(() => undefined);
    jest.spyOn(Date.prototype, 'toISOString').mockImplementation(() => {
      throw new Error('boom');
    });

    const request = mockRequest('GET');
    const response = await handler(request);
    const parsed = await parseResponse(response);

    expect(parsed.status).toBe(500);
    expect(parsed.body).toEqual({ error: 'Internal server error' });
    expect(logger.error).toHaveBeenCalledTimes(1);
  });

  it('includes CORS headers in responses', async () => {
    const request = mockRequest('GET');
    const response = await handler(request);

    expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
    expect(response.headers.get('Access-Control-Allow-Methods')).toBe('GET, POST, OPTIONS');
    expect(response.headers.get('Access-Control-Allow-Headers')).toBe(
      'Content-Type, Authorization, X-Request-ID',
    );
  });
});
