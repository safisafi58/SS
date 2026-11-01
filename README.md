# AI PROMPT

**AI PROMPT** — *Create Beyond Imagination.*

A curated AI image prompt library for Android. Dark premium design
(Dark Navy, Purple, Electric Blue). The app owner publishes prompts via a
secure admin panel; users browse, search, copy, favorite, share and download.

**No login. No registration. No user uploads. No comments.**

## Features

- Premium splash screen with smooth loading animation
- Home: featured carousel, categories, trending, latest, popular
- 24 categories with search and sorting
- Category details: banner, description, search, grid/list toggle, 4 sort modes
- Prompt details: fullscreen zoom viewer, copy, share, favorite, download, similar prompts
- Search across titles, descriptions, prompt text, categories and tags
- Favorites saved locally (no login needed)
- Trending ranked by real stats (Today / Week / Month / All Time)
- Notifications (admin announcements only)
- More menu: About, Contact, Privacy, Terms, Share, Rate
- Offline-friendly: cached images, local favorites/history, loading skeletons

## Demo Mode

The app ships with bundled sample data — it works **without any Firebase
account**. See `docs/FIREBASE_SETUP.md` to connect the real backend
(Firestore, Storage, admin-only security rules).

## Build

```bash
flutter pub get
flutter run            # debug
flutter build apk --release
```

Minimum SDK: Android 7.0 (API 24). English only.

## Project Structure

```
lib/
├── main.dart
├── data/          # models, repository (demo + Firebase-ready)
├── state/         # app state: favorites, searches, stats (local persistence)
├── services/      # clipboard, share, download, image loading
├── theme/         # dark premium theme
├── widgets/       # reusable cards, skeletons, empty states
└── screens/       # all 15+ screens
firebase/
└── firestore.rules  # read-only public, admin-only writes
docs/
└── FIREBASE_SETUP.md
```

## Security Model

- Regular users: read-only + local favorites. Never able to publish, edit or
  delete content.
- Admin: separate private panel with Firebase Authentication and a custom
  `admin` claim. No admin credentials inside the app.
- All write permissions enforced by Firestore security rules, not hidden buttons.
