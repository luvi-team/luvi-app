import { Langfuse } from "langfuse";

type SafeLangfuse = {
  instance?: Langfuse;
  safe: boolean;
};

export function createLangfuse(): SafeLangfuse {
  const pk = process.env.LANGFUSE_PUBLIC_KEY;
  const sk = process.env.LANGFUSE_SECRET_KEY;
  const host = process.env.LANGFUSE_HOST ?? "https://cloud.langfuse.com";

  if (!pk || !sk) {
    console.warn('Langfuse env vars missing, using stub mode');
    return {
      safe: false,
      instance: undefined,
    };
  }

  try {
    const lf = new Langfuse({
      publicKey: pk,
      secretKey: sk,
      baseUrl: host,
    });
    return { safe: true, instance: lf };
  } catch (error) {
    console.error('Failed to initialize Langfuse:', error);
    return { safe: false, instance: undefined };
  }
  return { safe: true, instance: lf };
}

