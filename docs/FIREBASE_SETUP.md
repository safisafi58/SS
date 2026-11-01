# Firebase Setup Guide — AI PROMPT

The app works in **demo mode** out of the box (bundled sample data, no Firebase needed).
Follow these steps to connect the real backend.

## 1. Create a Firebase project

1. Go to https://console.firebase.google.com and create a project (e.g. `ai-prompt`).
2. Add an **Android app** with package name `com.safisafi.ai_prompt`.
3. Download `google-services.json` and place it at `android/app/google-services.json`.

## 2. Firestore collections

```
prompts/{promptId}
  title, description, promptText, imageUrl, categoryId,
  tags[], publishedDate, featured, trending,
  views, copies, favorites, published

categories/{categoryId}
  name, imageUrl, description, promptCount

notifications/{notificationId}
  title, message, type, relatedPromptId, date
```

## 3. Security rules

Apply the rules from `firebase/firestore.rules` in this repo:

- Public users: **read-only** published prompts, categories, notifications.
- Copy/view counters: increment-only via `prompt_stats`.
- **Only admins** (custom auth token claim `admin == true`) can write content.
- No admin credentials exist inside the app — the admin panel is a separate
  private web app that signs in with Firebase Authentication.

Set the admin claim once from a trusted machine using the Firebase Admin SDK:

```js
admin.auth().setCustomUserClaims(uid, { admin: true });
```

## 4. Admin panel (separate private project)

Build a private admin web app (not shipped in this app) that uses Firebase
Authentication to sign in the owner and manages:
prompts, categories, featured content, trending flags, notifications.

## 5. Switch the app from demo to Firebase

1. Add to `pubspec.yaml`:

   ```yaml
   firebase_core: ^3.0.0
   cloud_firestore: ^5.0.0
   firebase_storage: ^12.0.0
   ```

2. Implement `PromptRepository` (in `lib/data/repository.dart`) with a
   `FirebasePromptRepository` class using the same models from
   `lib/data/models.dart`.

3. Replace `DemoPromptRepository()` usage with `FirebasePromptRepository()`.

## 6. Push notifications (optional)

- Add FCM to the project and upload a server key.
- The admin panel sends topic notifications; the app subscribes to the
  `announcements` topic.
