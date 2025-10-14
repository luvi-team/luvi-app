type LogLevel = 'info' | 'warn' | 'error';
type LogMeta = Record<string, unknown>;

const REDACTED_VALUE = '[REDACTED]';
const PII_KEYS = new Set(
  [
    'user_id',
    'userid',
    'email',
    'name',
    'full_name',
    'phone',
    'address',
    'ip_address',
    'cycle_phase',
    'lmp_date',
    'period_length',
    'symptoms',
    'health_data',
    'medical_history',
  ].map((key) => key.toLowerCase()),
);

const isPlainObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

const shouldRedactKey = (key: string): boolean => PII_KEYS.has(key.toLowerCase());

const redactUnknown = (value: unknown): unknown => {
  if (Array.isArray(value)) {
    return value.map((item) => redactUnknown(item));
  }

  if (isPlainObject(value)) {
    return Object.entries(value).reduce<Record<string, unknown>>((acc, [key, nestedValue]) => {
      if (shouldRedactKey(key)) {
        acc[key] = REDACTED_VALUE;
        return acc;
      }

      acc[key] = redactUnknown(nestedValue);
      return acc;
    }, {});
  }

  return value;
};

const redactPII = (obj: Record<string, unknown>): Record<string, unknown> => {
  return redactUnknown(obj) as Record<string, unknown>;
};

const sanitizeMeta = (meta?: LogMeta): Record<string, unknown> | undefined => {
  if (!meta) {
    return undefined;
  }

  if (!isPlainObject(meta)) {
    return redactUnknown(meta) as Record<string, unknown>;
  }

  return redactPII(meta);
};

const log = (level: LogLevel, message: string, meta?: LogMeta): void => {
  const sanitizedMeta = sanitizeMeta(meta);
  const timestamp = new Date().toISOString();

  const entry: Record<string, unknown> = {
    level,
    message,
    timestamp,
  };

  if (sanitizedMeta && typeof sanitizedMeta === 'object' && !Array.isArray(sanitizedMeta)) {
    const metaRecord: Record<string, unknown> = { ...sanitizedMeta };

    if (
      Object.prototype.hasOwnProperty.call(metaRecord, 'request_id') &&
      metaRecord.request_id != null
    ) {
      entry.request_id = String(metaRecord.request_id);
      delete metaRecord.request_id;
    }

    if (Object.keys(metaRecord).length > 0) {
      entry.meta = metaRecord;
    }
  }

  const serialized = JSON.stringify(entry);
  const fn = level === 'info' ? console.log : level === 'warn' ? console.warn : console.error;
  fn.call(console, serialized);
};

const logger = {
  info(message: string, meta?: LogMeta): void {
    log('info', message, meta);
  },
  warn(message: string, meta?: LogMeta): void {
    log('warn', message, meta);
  },
  error(message: string, meta?: LogMeta): void {
    log('error', message, meta);
  },
};

export type { LogMeta, LogLevel };
export { REDACTED_VALUE, redactPII };
export default logger;
