const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-120b';
const MAX_BODY_BYTES = 32 * 1024;
const MAX_MESSAGES = 32;
const MAX_COMPLETION_TOKENS = 2048;

function response(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'POST, GET, OPTIONS',
      'access-control-allow-headers': 'Content-Type',
    },
  });
}

function validMessages(messages) {
  return (
    Array.isArray(messages) &&
    messages.length > 0 &&
    messages.length <= MAX_MESSAGES &&
    messages.every(
      (message) =>
        message &&
        ['system', 'user', 'assistant'].includes(message.role) &&
        typeof message.content === 'string' &&
        message.content.length <= 12000,
    )
  );
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'OPTIONS') return response({}, 204);
    if (request.method === 'GET' && url.pathname === '/health') {
      return response({ status: 'ok' });
    }
    if (request.method !== 'POST' || url.pathname !== '/v1/chat/completions') {
      return response({ error: 'Not found.' }, 404);
    }
    if (!env.GROQ_API_KEY) {
      return response({ error: 'AI service is not configured.' }, 503);
    }
    const declaredLength = Number(request.headers.get('content-length') || 0);
    if (declaredLength > MAX_BODY_BYTES) {
      return response({ error: 'Request is too large.' }, 413);
    }

    let input;
    try {
      input = await request.json();
    } catch {
      return response({ error: 'Request body must be valid JSON.' }, 400);
    }
    if (
      new TextEncoder().encode(JSON.stringify(input)).length > MAX_BODY_BYTES ||
      !validMessages(input?.messages)
    ) {
      return response({ error: 'Invalid AI request.' }, 400);
    }
    const clientId = request.headers.get('x-resumate-client-id') || '';
    if (!/^[A-Za-z0-9_-]{32}$/.test(clientId)) {
      return response({ error: 'Invalid app installation identifier.' }, 400);
    }
    if (env.AI_RATE_LIMITER) {
      const { success } = await env.AI_RATE_LIMITER.limit({ key: clientId });
      if (!success) {
        return response(
          { error: 'Request limit reached. Try again in a minute.' },
          429,
        );
      }
    }

    const requestedTokens = Number(input.max_completion_tokens);
    const payload = {
      model: MODEL,
      messages: input.messages,
      temperature:
        typeof input.temperature === 'number'
          ? Math.max(0, Math.min(input.temperature, 1.2))
          : 0.3,
      max_completion_tokens:
        Number.isInteger(requestedTokens) && requestedTokens > 0
          ? Math.min(requestedTokens, MAX_COMPLETION_TOKENS)
          : 1500,
      reasoning_effort: 'low',
    };
    if (input.response_format?.type === 'json_object') {
      payload.response_format = { type: 'json_object' };
    }

    let upstream;
    try {
      upstream = await fetch(GROQ_ENDPOINT, {
        method: 'POST',
        headers: {
          authorization: `Bearer ${env.GROQ_API_KEY}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify(payload),
      });
    } catch {
      return response({ error: 'AI provider is temporarily unavailable.' }, 502);
    }
    if (!upstream.ok) {
      const status = upstream.status === 429 ? 429 : 502;
      return response(
        {
          error:
            upstream.status === 429
              ? 'AI service is busy. Try again shortly.'
              : 'AI provider request failed.',
        },
        status,
      );
    }
    return new Response(upstream.body, {
      status: 200,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'cache-control': 'no-store',
        'access-control-allow-origin': '*',
      },
    });
  },
};
