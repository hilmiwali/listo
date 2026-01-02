# Quick Start Guide - Listo

Get Listo up and running in 10 minutes!

## Prerequisites Check

Make sure you have:
- [ ] Flutter 3.10+ installed (`flutter --version`)
- [ ] Firebase account created
- [ ] Code editor ready (VS Code recommended)

## Step 1: Get the Code (1 min)

```bash
git clone https://github.com/yourusername/listo.git
cd listo
flutter pub get
```

## Step 2: Firebase Setup (5 min)

### Quick Firebase Configuration

1. **Create Project**
   - Go to [console.firebase.google.com](https://console.firebase.google.com)
   - Click "Add project"
   - Name it "listo"
   - Click through the wizard

2. **Enable Services**
   - **Authentication** → Enable Email/Password and Google
   - **Firestore** → Create database (start in test mode)
   - **Cloud Messaging** → Automatic, nothing to do

3. **Add Demo User**
   - Go to Authentication → Users → Add user
   - Email: `demo@listo.app`
   - Password: `Demo123!`

4. **Security Rules** (Copy-paste)
   - Go to Firestore → Rules
   - Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 3: Connect Flutter to Firebase (3 min)

### Option A: FlutterFire CLI (Recommended)
```bash
# Install CLI
dart pub global activate flutterfire_cli

# Configure
flutterfire configure
# Select your project
# Select all platforms you want
```

### Option B: Manual Setup
See `SETUP.md` for detailed manual setup instructions.

## Step 4: Run the App (1 min)

```bash
# Run on connected device
flutter run

# Or specify platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d macos         # macOS
```

## Step 5: Test It Out!

1. **Login**
   - Use demo credentials: demo@listo.app / Demo123!

2. **Try Voice Command**
   - Tap the microphone button
   - Say: "Remind me to test Listo at 3 pm"
   - Wait for voice confirmation

3. **Check Sync**
   - Create a task on one device
   - Open app on another device
   - Task should appear within 2 seconds

## Troubleshooting

### Build Fails?
```bash
flutter clean
flutter pub get
flutter run
```

### Can't Connect to Firebase?
- Check you ran `flutterfire configure`
- Verify Firebase project name matches
- Check internet connection

### Voice Not Working?
- Grant microphone permission when prompted
- Check device has microphone access
- Try speaking more clearly

## Next Steps

- 📖 Read `USER_GUIDE.md` for features
- 🔧 See `SETUP.md` for advanced configuration
- 🏗️ Check `PROJECT_SUMMARY.md` for architecture
- 🚀 Build for release when ready

## Quick Commands Reference

```bash
# Development
flutter run                    # Run app
flutter clean                  # Clean build
flutter pub get               # Get dependencies

# Testing
flutter test                   # Run tests
flutter analyze               # Check for issues

# Building
flutter build apk             # Android APK
flutter build ios             # iOS build
flutter build web             # Web build
flutter build windows         # Windows build
flutter build macos           # macOS build
```

## Get Help

- 📧 Email: support@listo.app
- 🐛 Issues: GitHub Issues
- 📚 Docs: See README.md and other guides

---

**You're all set! Happy organizing with Listo! 🎯**
