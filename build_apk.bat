@echo off
rem Builds a release APK with the Groq key baked in, so it works for anyone
rem you share it with. The key lives in .env (git-ignored), never in the repo.
cd /d "%~dp0"

findstr /r /c:"^GROQ_API_KEY=gsk_" .env >nul 2>&1
if errorlevel 1 (
  echo Missing Groq key. Create a file named .env in this folder containing:
  echo     GROQ_API_KEY=gsk_...
  echo Save it as plain text ^(ANSI/UTF-8^). Get a key at https://console.groq.com/keys
  pause
  exit /b 1
)

call flutter build apk --release --dart-define-from-file=.env
if errorlevel 1 (
  echo Build failed. Run "flutter doctor" and fix anything marked under Android.
  pause
  exit /b 1
)

echo.
echo Share this file: build\app\outputs\flutter-apk\app-release.apk
explorer build\app\outputs\flutter-apk
pause
