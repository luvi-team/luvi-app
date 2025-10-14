import logger, { REDACTED_VALUE } from '../../utils/logger';

const ISO_8601_REGEX =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;

const parseLogOutput = (spy: jest.SpyInstance): Record<string, unknown> => {
  expect(spy).toHaveBeenCalledTimes(1);
  const call = spy.mock.calls[0];
  expect(call).toHaveLength(1);

  const payload = call[0];
  expect(typeof payload).toBe('string');

  return JSON.parse(payload as string) as Record<string, unknown>;
};

const expectRedacted = (obj: Record<string, unknown>, key: string): void => {
  expect(obj[key]).toBe(REDACTED_VALUE);
};

describe('logger utility', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('info() logs message with correct format', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test message', { key: 'value' });

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.level).toBe('info');
    expect(logEntry.message).toBe('Test message');
    expect(typeof logEntry.timestamp).toBe('string');
    expect((logEntry.timestamp as string)).toMatch(ISO_8601_REGEX);
    expect(logEntry.meta).toEqual({ key: 'value' });
  });

  it('warn() logs message with correct format', () => {
    const consoleSpy = jest.spyOn(console, 'warn').mockImplementation(() => undefined);
    logger.warn('Warning message');

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.level).toBe('warn');
    expect(logEntry.message).toBe('Warning message');
    expect((logEntry.timestamp as string)).toMatch(ISO_8601_REGEX);
    expect(logEntry.meta).toBeUndefined();
  });

  it('error() logs message with correct format', () => {
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => undefined);
    logger.error('Error message', { error_type: 'TestError' });

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.level).toBe('error');
    expect(logEntry.message).toBe('Error message');
    expect((logEntry.timestamp as string)).toMatch(ISO_8601_REGEX);
    expect(logEntry.meta).toEqual({ error_type: 'TestError' });
  });

  it('redacts user_id from meta', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', { user_id: '12345' });

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.meta).toEqual({ user_id: REDACTED_VALUE });
  });

  it('redacts email from meta', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', { email: 'user@example.com' });

    const logEntry = parseLogOutput(consoleSpy);
    expectRedacted(logEntry.meta as Record<string, unknown>, 'email');
  });

  it('redacts multiple pii fields while keeping safe fields', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', {
      user_id: '123',
      email: 'user@example.com',
      name: 'John Doe',
      allowed_key: 'value',
    });

    const logEntry = parseLogOutput(consoleSpy);
    const meta = logEntry.meta as Record<string, unknown>;
    expectRedacted(meta, 'user_id');
    expectRedacted(meta, 'email');
    expectRedacted(meta, 'name');
    expect(meta.allowed_key).toBe('value');
  });

  it('redacts nested pii fields recursively', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', { nested: { user_id: '123', safe: 'value' } });

    const logEntry = parseLogOutput(consoleSpy);
    const meta = logEntry.meta as Record<string, unknown>;
    const nested = meta.nested as Record<string, unknown>;
    expectRedacted(nested, 'user_id');
    expect(nested.safe).toBe('value');
  });

  it('redacts health data fields', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', {
      cycle_phase: 'follicular',
      lmp_date: '2025-01-01',
      symptoms: ['cramps'],
    });

    const logEntry = parseLogOutput(consoleSpy);
    const meta = logEntry.meta as Record<string, unknown>;
    expectRedacted(meta, 'cycle_phase');
    expectRedacted(meta, 'lmp_date');
    expectRedacted(meta, 'symptoms');
  });

  it('keeps safe fields such as request_id and status_code', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test', {
      request_id: 'req-123',
      status_code: 200,
      endpoint: '/api/health',
    });

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.request_id).toBe('req-123');
    expect(logEntry.meta).toEqual({
      status_code: 200,
      endpoint: '/api/health',
    });
  });

  it('handles undefined meta without adding meta field', () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => undefined);
    logger.info('Test');

    const logEntry = parseLogOutput(consoleSpy);
    expect(logEntry.meta).toBeUndefined();
  });
});
