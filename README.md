# ResuMate AI

ResuMate AI is a Flutter resume builder. Resume editing, local drafts, templates,
PDF export, and LaTeX export work offline. AI features call the ResuMate backend;
the app never stores or sends a Groq API key.

## AI backend

`backend/worker.js` is a Cloudflare Worker proxy for Groq. Every AI feature in
the app uses `ApiService.chat`, which sends requests to the configured Worker.
The Worker pins the model and adds the same server-side `GROQ_API_KEY` to every
provider request. It validates request size and message shape, caps completion
tokens, and never returns the provider credential to the app.
The Worker rate-limits each app installation to 30 AI requests per minute.

Configure and deploy the backend:

```bash
cd backend
npm test
npx wrangler login
npx wrangler secret put GROQ_API_KEY
npx wrangler deploy
```

Enter the Groq key in Wrangler's interactive prompt. Do not put it in source,
`wrangler.toml`, a Flutter build define, or the APK. For local backend work,
copy `.dev.vars.example` to `.dev.vars`, set the local key there, then run
`npm run dev`.

Cloudflare's deployment prints the Worker URL. Build the mobile app with that
public URL (it is not a secret):

```bash
cd ..
flutter pub get
flutter build apk --release --dart-define=AI_BACKEND_URL=https://YOUR-WORKER.YOUR-ACCOUNT.workers.dev
```

If `AI_BACKEND_URL` is not supplied, the app shows that the AI service is not
configured. Deploy the Worker and rebuild with its URL before distributing an
AI-enabled APK. Cloudflare secret configuration is documented at
[Workers secrets](https://developers.cloudflare.com/workers/configuration/secrets/).

## Run and test the Flutter app

```bash
flutter pub get
flutter run --dart-define=AI_BACKEND_URL=https://YOUR-WORKER.YOUR-ACCOUNT.workers.dev
flutter test
```
