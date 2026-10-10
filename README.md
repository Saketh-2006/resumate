# Resumate AI

A Flutter career assistant powered by Groq's `openai/gpt-oss-120b` model. The app includes chat prompts for resume reviews, interview preparation, cover letters, and job-search advice.

## Run the app

1. Install Flutter and connect an Android or iOS device (or start an emulator).
2. From this directory, run `flutter pub get`.
3. To use the local testing key, start the app with `flutter run --dart-define-from-file=secrets.json`. Otherwise, launch normally and tap the key icon to enter a Groq API key. Keys are stored using the platform's secure storage.

The app sends chat requests to `https://api.groq.com/openai/v1/chat/completions`. Create or manage keys in the [Groq Console](https://console.groq.com/keys). If a key was shared publicly, revoke it and create a new one before use.

## Security note

Device secure storage protects the saved key at rest, but a mobile client must still use the key to make requests. For a publicly distributed app, put Groq calls behind your own authenticated backend so the Groq key is never distributed to users' devices. Never commit an API key to this repository.
