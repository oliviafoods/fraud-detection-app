# Quick Start Guide - From Zero to APK

This guide helps you build the Fraud Detection APK even if you've never used Flutter before.

## ⏱️ Time Required
- First-time setup: 30-45 minutes
- Building APK: 5-10 minutes

---

## Step 1: Install Flutter (One-Time Setup)

### Windows

1. **Download Flutter**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download Flutter SDK ZIP file
   - Extract to `C:\src\flutter`

2. **Update PATH**
   - Search "Environment Variables" in Windows
   - Edit "Path" in User Variables
   - Add: `C:\src\flutter\bin`
   - Click OK

3. **Verify Installation**
   ```cmd
   flutter doctor
   ```

### Mac

1. **Download Flutter**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.5-stable.zip
   unzip flutter_macos_3.24.5-stable.zip
   ```

2. **Update PATH**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify Installation**
   ```bash
   flutter doctor
   ```

### Linux

1. **Download Flutter**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
   tar xf flutter_linux_3.24.5-stable.tar.xz
   ```

2. **Update PATH**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Verify Installation**
   ```bash
   flutter doctor
   ```

---

## Step 2: Install Android SDK

### Option A: Install Android Studio (Recommended)

1. **Download Android Studio**
   - Go to: https://developer.android.com/studio
   - Download and install

2. **Open Android Studio**
   - Complete setup wizard
   - Install Android SDK
   - Install Android SDK Command-line Tools

3. **Accept Licenses**
   ```bash
   flutter doctor --android-licenses
   ```
   Press 'y' to accept all licenses

### Option B: Command-line Only (Advanced)

```bash
# Download command-line tools from:
# https://developer.android.com/studio#command-tools

# Extract and install
unzip commandlinetools-*.zip
./cmdline-tools/bin/sdkmanager --sdk_root=$HOME/Android/Sdk --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Accept licenses
flutter doctor --android-licenses
```

---

## Step 3: Verify Setup

```bash
flutter doctor
```

You should see:
```
✓ Flutter (Channel stable, 3.24.5)
✓ Android toolchain - develop for Android devices
✓ Android Studio (version 2023.1)
```

Don't worry about iOS setup (not needed for this project).

---

## Step 4: Download Project Files

If you're building on a different machine:

1. **Copy project folder**
   - Copy `/app/fraud_detection_app/` to your local machine
   - Also copy `/app/backend/` if you want to run backend locally

2. **Or download from GitHub** (if uploaded there)
   ```bash
   git clone https://github.com/your-repo/fraud-detection-app.git
   cd fraud-detection-app
   ```

---

## Step 5: Build APK

### Navigate to Project
```bash
cd /app/fraud_detection_app
# Or your local path: cd ~/Downloads/fraud_detection_app
```

### Install Dependencies
```bash
flutter pub get
```

This downloads all required packages (~2-3 minutes).

### Build Release APK
```bash
flutter build apk --release
```

**First build takes 5-10 minutes** as Flutter compiles everything.

### Locate APK
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

**File size**: ~20-30 MB

---

## Step 6: Install on Android Device

### Method 1: USB Cable (Recommended)

1. **Enable Developer Options**
   - Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect Phone**
   - Connect phone to computer via USB
   - Allow USB debugging when prompted

3. **Install APK**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### Method 2: Transfer File

1. **Copy APK to Phone**
   - Via USB: Copy `app-release.apk` to phone storage
   - Via Email: Email APK to yourself and download on phone
   - Via Drive: Upload to Google Drive and download on phone

2. **Install on Phone**
   - Open file manager on phone
   - Tap on `app-release.apk`
   - Allow "Install from Unknown Sources" if prompted
   - Tap "Install"

---

## Step 7: First Run Setup

### 1. Grant Permissions
When you open the app for the first time:
- Tap "Allow" for Phone permission
- Tap "Allow" for Microphone permission

If you accidentally deny:
- Go to Settings > Apps > Fraud Detection > Permissions
- Enable Phone and Microphone

### 2. Configure Backend URL

**IMPORTANT**: The app needs to connect to the backend.

#### Option A: Use Emergent Backend (If Running)
```dart
// In lib/services/api_service.dart, line 12:
static const String baseUrl = 'http://YOUR_SERVER_IP:8001/api';
```

#### Option B: Run Backend Locally
1. Start backend on your computer:
   ```bash
   cd /app/backend
   pip install -r requirements.txt
   python -m uvicorn server:app --host 0.0.0.0 --port 8001
   ```

2. Get your computer's IP:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

3. Update Flutter app with your IP:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8001/api';
   ```

4. Rebuild APK:
   ```bash
   flutter build apk --release
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

### 3. Enable Call Monitoring
- Open app
- Go to "Settings" tab
- Toggle "Enable Monitoring" ON
- You'll see a persistent notification (this is normal)

---

## Step 8: Test the App

### Test Flow:
1. Make a test call (call your own number or a friend)
2. Have a conversation
3. End the call
4. Wait 30 seconds for analysis
5. Open Fraud Detection app
6. Check "Home" tab for result
7. View "History" tab for all analyzed calls

### Expected Result:
- Home screen shows color-coded badge:
  - 🟢 Green = SAFE
  - 🟠 Orange = SUSPICIOUS  
  - 🔴 Red = FRAUD
- Fraud score (0-100)
- Explanation text
- Phone number and timestamp

---

## Troubleshooting

### Issue: `flutter: command not found`
**Solution**: Add Flutter to PATH (see Step 1)

### Issue: `Android licenses not accepted`
**Solution**: Run `flutter doctor --android-licenses` and accept all

### Issue: Build fails with "SDK not found"
**Solution**: 
1. Install Android Studio
2. Open it once to complete setup
3. Run `flutter doctor`

### Issue: APK installs but crashes
**Solution**:
1. Check logcat: `adb logcat | grep -i error`
2. Verify permissions are granted
3. Check backend URL is correct
4. Ensure backend is running

### Issue: Backend not connecting
**Solution**:
1. Test backend: `curl http://YOUR_IP:8001/api/health`
2. Ensure phone and computer on same WiFi
3. Check firewall settings
4. Try using computer's IP instead of localhost

### Issue: Call not being recorded
**Solution**:
- This is an Android limitation on some devices
- Try testing on a different device
- Check logcat for errors: `adb logcat | grep CallMonitor`

### Issue: Analysis taking too long
**Solution**:
- Normal analysis takes 30-60 seconds
- Check internet connection
- Verify backend has OpenAI API key
- Check backend logs for errors

---

## Common Questions

### Q: Do I need to keep the backend running?
**A**: Yes, the app needs the backend for AI analysis. You can:
- Keep backend running on your computer
- Deploy backend to a cloud server (AWS, Google Cloud)
- Use the Emergent backend if it's still running

### Q: Can I use this without internet?
**A**: No, the app requires internet for:
- Sending audio to backend
- AI analysis (Whisper + GPT-4)
You can view history offline, but new calls need internet.

### Q: How much does it cost to run?
**A**: 
- App: Free
- OpenAI API: ~$0.04 per call
- 100 calls/month ≈ $4

### Q: Is my data safe?
**A**: 
- All recordings stored locally on device
- Audio sent to backend only for analysis
- No cloud storage by default
- You control all data

### Q: Can I customize the app?
**A**: Yes! The code is well-documented. Common customizations:
- Change colors in `main.dart`
- Modify text sizes in `main.dart`
- Add Hindi language in `settings_screen.dart`
- Adjust fraud detection logic in `server.py`

### Q: Why is the app asking for so many permissions?
**A**:
- Phone: To detect incoming calls
- Microphone: To record calls
- Foreground Service: To run in background
All permissions are necessary for the app to work.

---

## Next Steps After Building

1. **Test with Real Calls**
   - Try different types of calls
   - Test with fraudulent patterns (simulate)
   - Verify accuracy

2. **Get Feedback**
   - Show to 2-3 senior citizens
   - Observe how they use it
   - Note confusion points

3. **Iterate**
   - Fix bugs discovered
   - Improve UX based on feedback
   - Add requested features

4. **Deploy Backend to Cloud** (Optional)
   - AWS, Google Cloud, or Azure
   - Get a permanent URL
   - Update app with production URL

5. **Publish to Play Store** (Optional)
   - Create Google Play Developer account ($25 one-time)
   - Prepare store listing
   - Upload APK
   - Launch!

---

## Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Android Developer Guide**: https://developer.android.com
- **OpenAI API Docs**: https://platform.openai.com/docs
- **Project Documentation**: See `TECHNICAL_DOCS.md`

---

## Success Checklist

- [ ] Flutter installed and working
- [ ] Android SDK installed
- [ ] Project dependencies downloaded (`flutter pub get`)
- [ ] APK built successfully
- [ ] APK installed on device
- [ ] Permissions granted
- [ ] Backend URL configured
- [ ] Backend is running
- [ ] Call monitoring enabled
- [ ] Test call completed
- [ ] Analysis result displayed

---

## Support

If you get stuck:
1. Check `BUILD_INSTRUCTIONS.md` for detailed steps
2. Review `TECHNICAL_DOCS.md` for architecture
3. Check Flutter documentation
4. Search error messages online

---

**You're ready to build! Start with Step 1 and work through each step carefully.** 🚀

Good luck! 🎉
