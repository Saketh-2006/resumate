# Resumate

A Flutter app that walks you through building a resume section by section,
saves drafts on the device, and exports a PDF. AI help comes from Groq's free
`openai/gpt-oss-120b` model, called directly from the app with no laptop or
backend needed.

## What works offline

- Building a resume (personal info, education, skills, projects, experience,
  certifications, achievements)
- Templates, colours and font size
- Saving and opening drafts (stored on the device)
- PDF export and `.tex` download
- Uploading a PDF resume and the section checklist

## What needs internet

AI polish, summary writing, quick edits, wording suggestions on uploaded
resumes, and both chat assistants. Without a connection these show a clear
"you're offline" message; nothing else breaks.

## Run it

```bash
flutter pub get
flutter run
```

The Groq key is compiled into the app from `.env`; users never enter it.

```bash
cp .env.example .env          # then put your key from console.groq.com/keys in it
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

Without the key the app still works; AI features say they aren't set up.

> Anything compiled into an app can be extracted from the APK. Fine for
> personal builds; for a public release, put Groq behind a small proxy.

## Test

```bash
flutter test
```
