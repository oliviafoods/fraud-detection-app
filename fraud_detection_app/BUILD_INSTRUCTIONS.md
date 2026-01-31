# Flutter Build Instructions

## Prerequisites

1. **Install Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH
   - Run: `flutter doctor` to verify installation

2. **Install Android Studio** (or Android SDK)
   - Download from: https://developer.android.com/studio
   - Install Android SDK Platform 34
   - Accept Android licenses: `flutter doctor --android-licenses`

3. **Enable Developer Mode on Android Device**
   - Settings > About Phone > Tap "Build Number" 7 times
   - Settings > Developer Options > Enable "USB Debugging"

## Build APK

### Step 1: Navigate to Project Directory
```bash
cd /app/fraud_detection_app
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Build Release APK
```bash
flutter build apk --release
```

This will take 5-10 minutes on first build.

### Step 4: Locate APK
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Install APK on Device

### Method 1: Via USB (ADB)
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Transfer and Install
1. Copy `app-release.apk` to your phone
2. Open the file on your phone
3. Allow "Install from Unknown Sources" if prompted
4. Tap "Install"

## Backend Setup

The backend is already running at `/app/backend/`

### Update Backend URL in Flutter App

Edit `/app/fraud_detection_app/lib/services/api_service.dart`:

```dart
// For testing with device on same network
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8001/api';

// For emulator
static const String baseUrl = 'http://10.0.2.2:8001/api';

// For production
static const String baseUrl = 'https://your-backend-url.com/api';
```

Get your computer's IP:
- **Windows**: `ipconfig` (look for IPv4 Address)
- **Mac/Linux**: `ifconfig` or `ip addr` (look for inet address)

## Testing

1. Install APK on Android device
2. Open the app
3. Grant all permissions (Phone, Microphone)
4. Go to Settings tab
5. Enable "Call Monitoring"
6. Make a test call
7. After call ends, check Home tab for result

## Troubleshooting

### Flutter Not Found
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Android Licenses Not Accepted
```bash
flutter doctor --android-licenses
```

### Build Fails
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Backend Not Connecting
- Ensure backend is running: `curl http://localhost:8001/api/health`
- Update `baseUrl` in `api_service.dart` with your computer's IP
- Ensure phone and computer are on same WiFi network

### Permissions Not Working
- Go to Android Settings > Apps > Fraud Detection > Permissions
- Enable Phone and Microphone manually

### Call Recording Not Working
- This is a known Android limitation on some devices/versions
- Try different Android versions or devices
- Check logcat for errors: `adb logcat | grep CallMonitor`

## Next Steps

1. Test the MVP on a real device
2. Gather feedback from senior citizens
3. Iterate based on real-world usage
4. Consider adding:
   - Voice alerts (Text-to-Speech)
   - Emergency contacts notifications
   - Multilingual support (Hindi, regional languages)
   - Whitelist/Blacklist numbers

## Important Notes

- **Call Recording**: May not work on all Android devices due to platform restrictions
- **Privacy**: All data is stored locally on the device
- **AI Cost**: Uses OpenAI API - monitor usage
- **MVP**: This is a simple, functional MVP. Production apps need more testing and features.

## Support

For issues:
1. Check logcat: `adb logcat`
2. Check backend logs: `tail -f /var/log/supervisor/backend.err.log`
3. Review Flutter logs in Android Studio
