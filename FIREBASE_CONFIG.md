# Firebase Configuration

This project uses Firebase for backend services. The configuration files are **not tracked in Git** for security reasons.

## Configuration Files

The following Firebase configuration files are required to build and run the app:

| File | Location | Platform |
|------|----------|----------|
| `google-services.json` | `android/app/` | Android |
| `GoogleService-Info.plist` | `ios/Runner/` | iOS |
| `GoogleService-Info.plist` | `macos/Runner/` | macOS |
| `firebase_options.dart` | `lib/` | All (Flutter) |
| `firebase.json` | Project root | Firebase CLI |

## Backup Location

All Firebase configuration files are backed up at:

```
<YOUR_BACKUP_PATH>/
├── google-services.json          # Android
├── GoogleService-Info-ios.plist  # iOS
├── GoogleService-Info-macos.plist # macOS
├── firebase_options.dart         # Flutter
└── firebase.json                 # Firebase CLI
```

## Setup for New Developers

### Option 1: Copy from Backup

If you have access to the backup directory:

```bash
# Copy Android config
cp <YOUR_BACKUP_PATH>/google-services.json android/app/

# Copy iOS config
cp <YOUR_BACKUP_PATH>/GoogleService-Info-ios.plist ios/Runner/GoogleService-Info.plist

# Copy macOS config
cp <YOUR_BACKUP_PATH>/GoogleService-Info-macos.plist macos/Runner/GoogleService-Info.plist

# Copy Flutter options
cp <YOUR_BACKUP_PATH>/firebase_options.dart lib/

# Copy Firebase CLI config
cp <YOUR_BACKUP_PATH>/firebase.json .
```

### Option 2: Generate New Configs

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for the project:
   ```bash
   flutterfire configure
   ```

3. Download platform-specific configs from [Firebase Console](https://console.firebase.google.com/):
   - Android: Project Settings → Your apps → Download `google-services.json`
   - iOS/macOS: Project Settings → Your apps → Download `GoogleService-Info.plist`

## Security Notes

- ⚠️ **Never commit these files to version control**
- These files contain API keys and project identifiers
- The `.gitignore` is configured to exclude all Firebase config files
- Share these files securely with team members (not via public channels)

## Firebase Services Used

- Firebase Authentication
- Cloud Firestore
- (Add other services as needed)
