import assert from 'node:assert/strict';
import { test } from 'node:test';
import worker from './worker.js';

const makeRequest = (body) =>
  new Request('https://worker.test/v1/chat/completions', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-resumate-client-id': '0123456789abcdefghijklmnopqrstuv',
    },
    body: JSON.stringify(body),
  });

test('all provider calls use the one server-side Groq key and fixed model', async () => {
  const originalFetch = globalThis.fetch;
  const calls = [];
  globalThis.fetch = async (url, options) => {
    calls.push({ url, options });
    return Response.json({ choices: [{ message: { content: 'ok' } }] });
  };
  try {
    const env = { GROQ_API_KEY: 'test-secret' };
    for (let i = 0; i < 2; i++) {
      const result = await worker.fetch(
        makeRequest({ messages: [{ role: 'user', content: 'hello' }], model: 'attacker-model' }),
        env,
      );
      assert.equal(result.status, 200);
    }
    assert.equal(calls.length, 2);
    for (const call of calls) {
      assert.equal(call.options.headers.authorization, 'Bearer test-secret');
      const payload = JSON.parse(call.options.body);
      assert.equal(payload.model, 'openai/gpt-oss-120b');
    }
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('invalid requests are rejected before contacting Groq', async () => {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async () => {
    throw new Error('should not be called');
  };
  try {
    const result = await worker.fetch(makeRequest({ messages: [] }), {
      GROQ_API_KEY: 'test-secret',
    });
    assert.equal(result.status, 400);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test('the configured per-installation limiter stops excess calls', async () => {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async () => {
    throw new Error('rate-limited request must not reach Groq');
  };
  try {
    const result = await worker.fetch(
      makeRequest({ messages: [{ role: 'user', content: 'hello' }] }),
      {
        GROQ_API_KEY: 'test-secret',
        AI_RATE_LIMITER: { limit: async () => ({ success: false }) },
      },
    );
    assert.equal(result.status, 429);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
