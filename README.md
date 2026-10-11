# Resumate

A Flutter app that walks you through building a resume one section at a time,
on a notebook-paper theme with light and dark modes.

**Works offline:** building and editing resumes, profile photo, saved drafts,
templates and colours, PDF export, `.tex` export, and the checklist for an
uploaded PDF resume.

**Needs internet:** the AI features (polish the whole resume, write a summary,
quick edits, wording suggestions on uploads, and the career-assistant chat).
They call Groq's free `openai/gpt-oss-120b` model directly from the phone. There
is no backend server.

## One-time setup (Windows)

1. Install [Flutter](https://docs.flutter.dev/get-started/install/windows/mobile)
   and [Android Studio](https://developer.android.com/studio). Open Android
   Studio once so it installs the Android SDK.
2. In PowerShell, check that everything is ready:

   ```powershell
   flutter doctor
   ```

   Fix anything marked with ✗ under **Flutter** and **Android toolchain**. If
   it asks you to, run `flutter doctor --android-licenses` and accept them.
3. Get the code, or update it if you already have it:

   ```powershell
   git clone https://github.com/Saketh-2006/resumate.git
   cd resumate
   ```

   ```powershell
   git pull
   ```

4. Get a free Groq API key at https://console.groq.com/keys.
5. In the `resumate` folder, save the key in a file named `.env`:

   ```powershell
   Set-Content -Path .env -Value "GROQ_API_KEY=gsk_your_key_here" -Encoding ascii
   ```

   Use exactly this command or Notepad. `echo ... > .env` in PowerShell saves
   the file as UTF-16, which Flutter can't read. `.env` is git-ignored, so the
   key stays on your laptop.

## Build an APK to share

Double-click **`build_apk.bat`** (or run `.\build_apk.bat` in PowerShell).

It checks that `.env` has your key, builds a release APK with the key inside,
and opens the folder containing:

```
build\app\outputs\flutter-apk\app-release.apk
```

Send that file to anyone. AI works on their phone with no setup, because the
key is inside the APK. Build a new APK the same way whenever the code changes.

When they install it, Android asks them to allow installing from this source.
That's normal for an APK that isn't from the Play Store.

## Good to know

- **Never commit the key.** This repo is public. GitHub reports leaked Groq
  keys and Groq revokes them, which would break AI in every APK you've shared.
- **Everyone shares one free key.** Groq's free tier limits requests per minute
  and per day across all users. With heavy use, people may see "Groq free-tier
  limit reached"; they can wait a minute, and the rest of the app keeps working.
- **The key can be extracted from the APK** by someone determined. If it gets
  abused, create a new key in the Groq console, update `.env`, and rebuild.
  Old APKs lose AI until people install the new one.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `build_apk.bat` says the Groq key is missing | Create `.env` as in setup step 5 and check it's in the same folder as `build_apk.bat`. |
| `'flutter' is not recognized` | Flutter isn't on your PATH. Follow the PATH step in the Flutter install guide, then open a new PowerShell window. |
| The build fails with an Android/SDK error | Run `flutter doctor` and fix the Android items. |
| The app says "This build has no Groq key" | The APK was built without `.env`. Rebuild with `build_apk.bat`. |
| AI says "You are offline" | The phone has no internet. Everything except AI still works. |

## Develop

```powershell
flutter pub get
flutter run --dart-define-from-file=.env
flutter test
flutter analyze
```

`--dart-define-from-file=.env` passes the key to the app. Without it, the app
runs but the AI features say they aren't set up.

### Where things are

| Path | What it does |
| --- | --- |
| `lib/api_service.dart` | Every Groq call and prompt. |
| `lib/features/home/` | Welcome page and workspace. |
| `lib/features/resume/` | Step-by-step editor, saved resumes, photo picker. |
| `lib/features/chat/` | Career assistant chat and its Markdown rendering. |
| `lib/resume_preview_screen.dart` | Preview, AI polish, quick edits, export. |
| `lib/services/` | Draft storage (on the device) and PDF/LaTeX export. |
| `lib/theme/` | Colours, dark mode, fonts, and the paper/handwriting animations. |
| `assets/fonts/`, `assets/icon/` | Bundled fonts (OFL licence) and the app icon source. |
