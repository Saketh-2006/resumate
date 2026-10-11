# Resumate

A Flutter resume builder. Building a resume, saved drafts, templates, PDF and
LaTeX export all work offline. AI features (polish, summaries, quick edits,
chat) call Groq's `openai/gpt-oss-120b` directly from the phone.

## Build an APK to share (Windows)

Needs Flutter and Android Studio (for the Android SDK); `flutter doctor` should
show no problems under Android.

1. Get a free key at https://console.groq.com/keys
2. In the project folder, create `.env` (git-ignored, never commit it). In
   PowerShell:

   ```powershell
   Set-Content -Path .env -Value "GROQ_API_KEY=gsk_your_key_here" -Encoding ascii
   ```

   (Don't use `echo ... > .env` in PowerShell; it saves UTF-16, which Flutter
   can't read.)

3. Double-click `build_apk.bat` (or run it from a terminal).

Share `build\app\outputs\flutter-apk\app-release.apk` (the script opens that
folder). The key is baked into the APK, so it works on any phone with no setup. The script refuses to build
without the key, so you can't ship an APK where AI silently doesn't work.

Don't commit the key: this repo is public, and GitHub reports leaked Groq keys
so Groq revokes them, which would break AI in every APK you've shared.

## Develop

```powershell
flutter pub get
flutter run --dart-define-from-file=.env
flutter test
```
