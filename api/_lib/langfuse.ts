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
    // Fallback: keine ENV gesetzt -> Stub, damit App nicht crasht
    return {
      safe: false,
      instance: undefined,
    };
  }

  const lf = new Langfuse({
    publicKey: pk,
    secretKey: sk,
    baseUrl: host,
  });

  return { safe: true, instance: lf };
}

