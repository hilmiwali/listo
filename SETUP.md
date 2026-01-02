# Listo Setup Guide

Complete guide for setting up Firebase and configuring Listo for all platforms.

## Prerequisites

Before you begin, ensure you have:
- [ ] Flutter SDK 3.10 or higher installed
- [ ] Firebase account (free tier works)
- [ ] Platform-specific development tools installed
- [ ] Text editor or IDE (VS Code, Android Studio, etc.)

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `listo` (or your preferred name)
4. Enable/disable Google Analytics (optional)
5. Click "Create project"

### 1.2 Enable Authentication

1. In Firebase Console, select your project
2. Go to "Authentication" in left sidebar
3. Click "Get Started"
4. Enable sign-in methods:
   - **Email/Password**: Toggle "Enable" and save
   - **Google**: Toggle "Enable", add support email, save

### 1.3 Create Firestore Database

1. Go to "Firestore Database" in sidebar
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your preferred location (closest to your users)
5. Click "Enable"

### 1.4 Set Up Cloud Messaging

1. Go to "Cloud Messaging" in sidebar
2. Note your Sender ID (you'll need this)
3. No additional setup required at this stage

### 1.5 Configure Firestore Security Rules

1. In Firestore Database, go to "Rules" tab
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tasks collection
    match /tasks/{taskId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && 
                                    resource.data.userId == request.auth.uid;
    }
    
    // Events collection
    match /events/{eventId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && 
                                    resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

## Step 2: Flutter Project Setup

### 2.1 Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### 2.2 Configure Firebase in Flutter

```bash
# Navigate to project directory
cd listo

# Run configuration
flutterfire configure

# Select your Firebase project
# Select platforms: Android, iOS, Web, Windows, macOS
```

This will create:
- `firebase_options.dart` in `lib/`
- Platform-specific configuration files

### 2.3 Update main.dart

The `main.dart` is already configured, but verify it has:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Step 3: Android Setup

### 3.1 Update build.gradle Files

**Project-level** (`android/build.gradle`):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**App-level** (`android/app/build.gradle`):
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

### 3.2 Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    
    <application
        android:label="Listo"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Notification receiver -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <!-- Firebase Messaging Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- Other configuration -->
    </application>
</manifest>
```

### 3.3 Google Sign-In SHA-1

1. Get your SHA-1 certificate:
```bash
cd android
./gradlew signingReport
```

2. Copy the SHA-1 hash
3. In Firebase Console:
   - Go to Project Settings
   - Scroll to "Your apps"
   - Select Android app
   - Add SHA-1 certificate fingerprint
   - Save

## Step 4: iOS Setup

### 4.1 Update Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Existing keys -->
    
    <!-- Microphone permission -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Listo needs microphone access for voice commands</string>
    
    <!-- Calendar permission -->
    <key>NSCalendarsUsageDescription</key>
    <string>Listo needs calendar access to schedule events</string>
    
    <!-- Notification permission -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
        <string>fetch</string>
    </array>
    
    <!-- Google Sign-In -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
            </array>
        </dict>
    </array>
</dict>
```

### 4.2 Update Podfile

Edit `ios/Podfile`:

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add this for Firebase
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '10.18.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### 4.3 Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

### 4.4 Apple Push Notification (APNs)

For push notifications on iOS:
1. In [Apple Developer](https://developer.apple.com/):
   - Go to Certificates, Identifiers & Profiles
   - Create Push Notification certificate
   - Download and install

2. In Firebase Console:
   - Go to Project Settings > Cloud Messaging
   - Upload APNs certificate
   - Save

## Step 5: Web Setup

### 5.1 Update index.html

Edit `web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Existing head content -->
  
  <!-- Firebase Configuration -->
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js"></script>
  
  <script>
    // Your web app's Firebase configuration
    const firebaseConfig = {
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_PROJECT_ID.appspot.com",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID"
    };
    
    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
  </script>
</head>
<body>
  <!-- Body content -->
</body>
</html>
```

Get your config from Firebase Console:
- Project Settings > General
- Scroll to "Your apps"
- Select Web app
- Copy config object

### 5.2 Enable Firebase Hosting (Optional)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
firebase init hosting

# Select your project
# Public directory: build/web
# Single-page app: Yes
# GitHub integration: Optional

# Deploy
flutter build web
firebase deploy --only hosting
```

## Step 6: Windows Setup

### 6.1 Enable Windows Support

```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

### 6.2 Windows Configuration

No additional Firebase configuration needed for Windows. The `firebase_options.dart` generated by FlutterFire CLI handles everything.

### 6.3 Build and Run

```bash
flutter build windows
flutter run -d windows
```

## Step 7: macOS Setup

### 7.1 Enable macOS Support

```bash
flutter config --enable-macos-desktop
flutter create --platforms=macos .
```

### 7.2 Update Entitlements

Edit `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
</dict>
</plist>
```

### 7.3 Build and Run

```bash
flutter build macos
flutter run -d macos
```

## Step 8: Create Demo Account

### 8.1 In Firebase Console

1. Go to Authentication > Users
2. Click "Add user"
3. Enter:
   - Email: demo@listo.app
   - Password: Demo123!
4. Click "Add user"

### 8.2 Test Demo Login

1. Run the app
2. Use demo credentials to sign in
3. Verify everything works

## Step 9: Verification Checklist

- [ ] Android app runs and authenticates
- [ ] iOS app runs and authenticates
- [ ] Web app runs and authenticates
- [ ] Windows app runs and authenticates (if using Windows)
- [ ] macOS app runs and authenticates (if using macOS)
- [ ] Voice commands work (microphone permission granted)
- [ ] Tasks sync across devices
- [ ] Events sync across devices
- [ ] Notifications appear
- [ ] Google Sign-In works
- [ ] Demo account works

## Troubleshooting

### Common Issues

**Build Errors**:
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Clear platform-specific caches
cd android && ./gradlew clean && cd ..
cd ios && pod deintegrate && pod install && cd ..
```

**Firebase Connection Issues**:
- Verify `google-services.json` (Android) in correct location
- Verify `GoogleService-Info.plist` (iOS) in correct location
- Check Firebase project settings match app bundle IDs
- Ensure SHA-1 certificate added (Android)

**Permission Issues**:
- Check all permissions in AndroidManifest.xml
- Check all usage descriptions in Info.plist
- Request permissions at runtime (handled by packages)

**Sync Not Working**:
- Check internet connection
- Verify Firestore security rules
- Check Firebase Console > Firestore > Data
- Look for errors in console logs

## Next Steps

1. Customize the app (colors, icons, name)
2. Add your own branding
3. Configure Google Play Console (Android)
4. Configure App Store Connect (iOS)
5. Set up CI/CD pipeline
6. Add analytics and crash reporting
7. Test on real devices
8. Prepare for production release

## Support

If you encounter issues:
- Check [Flutter documentation](https://docs.flutter.dev/)
- Check [Firebase documentation](https://firebase.google.com/docs)
- Open an issue on GitHub
- Contact support@listo.app

---

**Setup complete! Happy coding! 🚀**
