type BuildCorsOptions = {
  allowList?: string[];
  allowAll?: boolean;
};

const DEFAULT_METHODS = 'GET, POST, OPTIONS';
const DEFAULT_HEADERS = 'Content-Type, Authorization, X-Request-ID';

const normalizeOrigin = (origin: string): string => origin.trim();

const resolveAllowedOrigin = (
  originHeader: string | null,
  options: BuildCorsOptions,
): string => {
  if (options.allowAll) {
    return '*';
  }

  const allowList = options.allowList ?? [];
  if (allowList.length === 0) {
    return '*';
  }

  const normalizedAllowList = allowList.map(normalizeOrigin);

  if (originHeader) {
    const normalizedOrigin = normalizeOrigin(originHeader);
    if (normalizedAllowList.includes(normalizedOrigin)) {
      return normalizedOrigin;
    }
  }

  return normalizedAllowList[0];
};

export const buildCorsHeaders = (
  originHeader: string | null,
  options: BuildCorsOptions,
): Record<string, string> => {
  const allowOrigin = resolveAllowedOrigin(originHeader, options);

  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Methods': DEFAULT_METHODS,
    'Access-Control-Allow-Headers': DEFAULT_HEADERS,
  };
};

export type { BuildCorsOptions };
