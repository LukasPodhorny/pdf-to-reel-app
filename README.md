# pdftoreel

Turns one prompt/file into multiple short-form videos. Live at [pdftoreel.com](https://pdftoreel.com) 90 free credits currently included.

## Deployment

Two Firebase Hosting targets (see `firebase.json`):

- **`landing`** → [pdftoreel.com](https://pdftoreel.com) — static marketing page served from `landing/`.
- **`app`** → [app.pdftoreel.com](https://app.pdftoreel.com) — the Flutter web app built from `build/web`.

## Mobile app (beta)

Android/iOS builds are distributed via Firebase App Distribution. Join the testers and install:

- **Download:** [here](https://appdistribution.firebase.dev/i/3c23a4ce558c73cc)

You'll get an email from Firebase with install instructions. On iOS you may need to register your device UDID before a build is available.

## Stack

- **Flutter** (web + mobile + desktop targets configured)
- **Riverpod** for state management
- **Firebase Auth** (email/password + Google Sign-In) via project `pdf-to-reel-auth`
- **Dio** for the backend API (`lib/services/`)
