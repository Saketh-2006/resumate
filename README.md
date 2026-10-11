# Resumate

A Flutter resume builder. Building a resume, saved drafts, templates, PDF and
LaTeX export all work offline. AI features (polish, summaries, quick edits,
chat) call Groq's `openai/gpt-oss-120b` directly from the phone.

## Build an APK to share

1. Get a free key at https://console.groq.com/keys
2. Put it in `.env` (git-ignored, never commit it):

   ```bash
   cp .env.example .env   # then edit: GROQ_API_KEY=gsk_...
   ```

3. Build:

   ```bash
   ./build_apk.sh
   ```

Share `build/app/outputs/flutter-apk/app-release.apk`. The key is baked into the
APK, so it works on any phone with no setup. The script refuses to build
without the key, so you can't ship an APK where AI silently doesn't work.

Don't commit the key: this repo is public, and GitHub reports leaked Groq keys
so Groq revokes them, which would break AI in every APK you've shared.

## Develop

```bash
flutter pub get
flutter run --dart-define-from-file=.env
flutter test
```
