# Firebase Configuration Setup

This project uses Firebase for authentication, database, and cloud messaging. The Firebase configuration files are **NOT included** in this repository for security reasons.

## 🔥 Firebase Setup Instructions

### Prerequisites
- Flutter SDK installed
- Firebase CLI installed: `npm install -g firebase-tools`
- FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

### Step 1: Create Your Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable the following services:
   - **Authentication** (Email/Password and Google Sign-In)
   - **Cloud Firestore** (Database)
   - **Cloud Messaging** (Push Notifications)
   - **Firebase Storage** (Optional, for future features)

### Step 2: Configure Firebase for Flutter

Run the following command in the project root:

```bash
flutterfire configure
```

This will:
- Log you into Firebase
- Let you select/create a Firebase project
- Generate the following files (which are gitignored):
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `macos/Runner/GoogleService-Info.plist`

### Step 3: Configure Firebase Services

#### Enable Authentication:
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google Sign-In** (optional)
4. For Google Sign-In on Android, add your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

#### Setup Firestore Database:
1. In Firebase Console → **Firestore Database**
2. Create database in **test mode** (for development)
3. Add security rules (see `SETUP.md` for production rules)

#### Setup Cloud Messaging:
1. In Firebase Console → **Cloud Messaging**
2. No additional setup needed - configuration is automatic

### Step 4: Run the App

```bash
flutter pub get
flutter run
```

## 🔒 Security Notes

- **Never commit** Firebase config files to version control
- The `.gitignore` is configured to exclude:
  - `google-services.json`
  - `GoogleService-Info.plist`
  - `firebase_options.dart`
  - `firebase.json`
  - `.firebaserc`

## 📚 Additional Resources

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Listo Project Documentation](./README.md)
