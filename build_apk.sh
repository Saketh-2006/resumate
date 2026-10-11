#!/usr/bin/env bash
# Builds a release APK with the Groq key baked in, so it works for anyone
# you share it with. The key lives in .env (git-ignored), never in the repo.
set -euo pipefail
cd "$(dirname "$0")"

if ! grep -qE '^GROQ_API_KEY=gsk_[A-Za-z0-9]+' .env 2>/dev/null; then
  echo "Missing Groq key. Create .env with:  GROQ_API_KEY=gsk_..." >&2
  echo "(copy .env.example; get a key at https://console.groq.com/keys)" >&2
  exit 1
fi

flutter build apk --release --dart-define-from-file=.env
echo "Share this file: build/app/outputs/flutter-apk/app-release.apk"
