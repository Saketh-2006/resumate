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

Get a free key at https://console.groq.com/keys, then open
**Career assistant → key icon** in the app and paste it. The key is saved in
the device's secure storage.

For development you can bake a key in instead: create `secrets.json`
(git-ignored) containing `{"GROQ_API_KEY": "gsk_..."}` and run
`flutter run --dart-define-from-file=secrets.json`.

> Anything compiled into an app can be extracted. That's fine for personal
> builds; for a public release, put Groq behind a small proxy you control.

## Test

```bash
flutter test
```
