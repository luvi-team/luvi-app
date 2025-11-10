import { buildCorsHeaders } from '../../utils/cors.js';

describe('buildCorsHeaders', () => {
  it('returns wildcard when allowAll is true', () => {
    const headers = buildCorsHeaders('https://example.com', { allowAll: true });
    expect(headers['Access-Control-Allow-Origin']).toBe('*');
  });

  it('returns the origin when it is included in the allow list', () => {
    const origin = 'https://allowed.example';
    const headers = buildCorsHeaders(origin, { allowList: ['https://foo', origin] });
    expect(headers['Access-Control-Allow-Origin']).toBe(origin);
  });

  it('returns empty string when origin does not match allow list and allowAll is false', () => {
    const allowList = ['https://primary.example', 'https://secondary.example'];
    const headers = buildCorsHeaders('https://unknown.example', { allowList });
    expect(headers['Access-Control-Allow-Origin']).toBe('');
  });

  it('defaults to wildcard when allow list is empty', () => {
    const headers = buildCorsHeaders('https://example.com', { allowList: [] });
    expect(headers['Access-Control-Allow-Origin']).toBe('*');
  });
});
