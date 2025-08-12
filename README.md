# Library Management Flutter App (Starter)

This is a starter Flutter + Firebase project for a Library Management System.
It includes:
- Add / list books (each physical copy has unique ID)
- Borrow / Return flows (by Book ID)
- Dashboard statistics (total, available, borrowed)
- Modern, colorful UI with basic animations
- Firestore structure and service helper

## Important setup steps (you must do this)
1. Install Flutter SDK and ensure `flutter` works on your machine.
2. Create a Firebase project at https://console.firebase.google.com.
3. Add Android and/or iOS app in Firebase and download:
   - Android: `google-services.json` -> place under `android/app/`
   - iOS: `GoogleService-Info.plist` -> place under `ios/Runner/`
4. In `android/build.gradle` and `android/app/build.gradle` follow Firebase docs for Flutter.
5. Run `flutter pub get` in the project root.
6. Run the app:
   - `flutter run` (for a connected device or emulator)

## Firestore Collections used
- `books` (each document is a physical copy)
  Fields:
    - title (string)
    - author (string)
    - isbn (string)
    - copyId (string) // unique per copy, e.g., BK-0001
    - status (string) // "available" or "borrowed"
    - borrowerName (string) optional
    - borrowDate (timestamp) optional
    - dueDate (timestamp) optional
    - coverUrl (string) optional
- `transactions` (audit trail)

## Notes
- This starter focuses on Firestore logic and Flutter UI. Platform-specific Firebase files are NOT included.
- You can customize UI, colors, animations further.

Enjoy — Ayush :) 
