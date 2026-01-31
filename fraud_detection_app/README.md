# Fraud Detection App for Senior Citizens

## Simple MVP - AI-Powered Call Fraud Detection

This Android app helps senior citizens in India detect fraudulent phone calls using AI.

## Features
- 🎯 Real-time call monitoring
- 🤖 AI-powered fraud analysis (Whisper + GPT-4)
- 📊 Call history with risk categorization
- 🔒 Privacy-first (local storage only)
- 👴 Senior-friendly UI (large text, high contrast)

## Build Instructions

### Prerequisites
1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Install Android Studio or Android SDK
3. Enable Developer Mode on your Android device

### Build APK
```bash
cd fraud_detection_app
flutter pub get
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Install on Device
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Backend Setup
The backend API is at `/app/backend/` - it's already configured and running.

## Permissions Required
- READ_PHONE_STATE - Detect incoming calls
- RECORD_AUDIO - Record call audio
- FOREGROUND_SERVICE - Run monitoring service
- INTERNET - Send audio to AI API

## Architecture
- **Flutter**: UI layer (Dart)
- **Kotlin**: Native call detection + audio recording
- **FastAPI**: Backend for AI fraud analysis
- **OpenAI**: Whisper (transcription) + GPT-4 (fraud detection)

## Code Structure
```
lib/
  ├── main.dart           # App entry point
  ├── screens/
  │   ├── home_screen.dart      # Status display
  │   ├── history_screen.dart   # Call history
  │   └── settings_screen.dart  # App settings
  ├── models/
  │   └── call_record.dart      # Data model
  ├── services/
  │   ├── api_service.dart      # Backend API calls
  │   └── call_service.dart     # Platform channel
  └── widgets/
      └── risk_badge.dart       # Color-coded risk display

android/app/src/main/kotlin/
  └── CallMonitorService.kt    # Native call detection
```

## Testing
1. Install APK on Android device
2. Grant all permissions
3. Enable monitoring in Settings
4. Make a test call
5. Check result on Home screen
6. View history in History tab

## Notes
- MVP version - simple and functional
- Easy to read code with extensive comments
- No login, no cloud storage - privacy first
- Low battery usage
