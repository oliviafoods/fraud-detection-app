# Fraud Detection App - Technical Documentation

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│  (UI Layer)     │
└────────┬────────┘
         │
         ├─────────────────────────────────┐
         │                                 │
┌────────▼────────┐              ┌────────▼────────┐
│  Kotlin Native  │              │   FastAPI       │
│  Call Detection │              │   Backend       │
│  Audio Recording│              │   (AI Analysis) │
└─────────────────┘              └────────┬────────┘
                                          │
                                  ┌───────┴────────┐
                                  │                │
                          ┌───────▼──────┐  ┌─────▼──────┐
                          │   Whisper    │  │   GPT-4    │
                          │ (Speech-to-  │  │  (Fraud    │
                          │   Text)      │  │ Detection) │
                          └──────────────┘  └────────────┘
```

## Component Details

### 1. Flutter App (UI Layer)

**Location**: `/lib/`

**Screens**:
- `home_screen.dart` - Displays last call status with color-coded badge
- `history_screen.dart` - Shows all analyzed calls
- `settings_screen.dart` - Enable/disable monitoring, change language

**Services**:
- `api_service.dart` - Communicates with backend API
- `call_service.dart` - Platform channel to Kotlin native layer

**Models**:
- `call_record.dart` - Data model for call analysis result

**Design**: Senior-friendly UI with:
- Extra large text (20-32px)
- High contrast colors
- Simple navigation (3 tabs)
- Color-coded risk levels (Green/Orange/Red)

### 2. Kotlin Native Layer

**Location**: `/android/app/src/main/kotlin/com/fraud/detection/`

**Files**:
- `MainActivity.kt` - Platform channel host, permission handling
- `CallMonitorService.kt` - Foreground service for call monitoring

**Functionality**:
1. Detects incoming calls via `PhoneStateListener`
2. Starts audio recording when call is answered
3. Stops recording when call ends
4. Saves audio to local storage
5. Notifies Flutter app via SharedPreferences

**Permissions Required**:
- `READ_PHONE_STATE` - Detect call state changes
- `RECORD_AUDIO` - Record call audio
- `READ_CALL_LOG` - Get phone number (optional)
- `FOREGROUND_SERVICE` - Run background service

**Important Notes**:
- Call recording may not work on all devices (Android platform limitation)
- Uses `MediaRecorder.AudioSource.VOICE_COMMUNICATION`
- Runs as foreground service with notification

### 3. Backend API (FastAPI)

**Location**: `/app/backend/server.py`

**Endpoints**:

#### `GET /api/health`
Health check endpoint
```json
{"status": "ok", "message": "Backend is running"}
```

#### `POST /api/analyze-call`
Analyze call audio for fraud

**Request**: Multipart form data
- `audio` (file): Audio file (m4a format)
- `phone_number` (string): Caller's phone number

**Response**:
```json
{
  "id": "uuid",
  "phoneNumber": "+911234567890",
  "timestamp": "2024-01-15T10:30:00Z",
  "riskCategory": "FRAUD|SUSPICIOUS|SAFE",
  "fraudScore": 85,
  "reason": "Caller requested OTP and bank details",
  "transcript": "Full call transcript..."
}
```

#### `GET /api/call-history`
Get all analyzed calls

**Response**: Array of CallRecord objects

### 4. AI Pipeline

**Step 1: Speech-to-Text (Whisper)**
- Model: `whisper-1`
- Input: Audio file (m4a)
- Output: Text transcript (auto-detects Hindi/English)
- Library: `emergentintegrations.llm.openai.OpenAISpeechToText`

**Step 2: Fraud Analysis (GPT-4)**
- Model: `gpt-4o`
- Input: Transcript + phone number
- Output: Structured JSON with fraud score, category, reason
- Temperature: 0.3 (more deterministic)
- Response format: JSON mode

**Fraud Detection Patterns**:
- OTP/PIN requests
- Bank account details requests
- Threats or urgency tactics
- Impersonation (bank, government, police)
- Prize/lottery scams
- KYC update requests
- Fake customer support
- Investment scams

**Scoring**:
- 0-30: SAFE (normal conversation)
- 31-70: SUSPICIOUS (some red flags)
- 71-100: FRAUD (clear fraud indicators)

## Data Flow

1. User receives incoming call
2. Kotlin service detects call and starts recording
3. User answers and talks (call is recorded)
4. Call ends, recording stops
5. Kotlin saves audio file and notifies Flutter via SharedPreferences
6. Flutter app (on resume/periodic check) detects new audio
7. Flutter uploads audio + phone number to backend
8. Backend transcribes audio using Whisper
9. Backend analyzes transcript using GPT-4
10. Backend returns structured result
11. Flutter saves result locally and displays on Home screen
12. User sees color-coded risk level

## Storage

- **Local Storage (Flutter)**: SharedPreferences for call records (last 100)
- **Local Storage (Android)**: Audio files in app's external files directory
- **Database (MongoDB)**: Call records on backend (optional, for analytics)

## Security & Privacy

- All call data stored locally on device
- Audio sent to backend only for AI analysis
- No cloud storage of recordings
- User has full control (can delete history)
- Backend uses HTTPS in production

## Cost Considerations

**OpenAI API Costs** (approximate):
- Whisper: $0.006 per minute of audio
- GPT-4o: $5 per 1M input tokens, $15 per 1M output tokens

**Example**: 5-minute call
- Whisper: ~$0.03
- GPT-4 (500 tokens): ~$0.01
- **Total per call: ~$0.04**

For 100 calls/month: ~$4

## Limitations

1. **Call Recording**: May not work on all Android devices due to platform restrictions
2. **Background Processing**: iOS not supported in this MVP
3. **Network Required**: Needs internet for AI analysis
4. **Language**: Currently optimized for English and Hindi
5. **Real-time Analysis**: Analysis happens after call ends, not during

## Future Enhancements

1. **Real-time Alerts**: Analyze during call, alert user immediately
2. **Voice Alerts**: Text-to-speech warnings for non-readers
3. **Multilingual**: Support regional Indian languages
4. **Whitelist/Blacklist**: Allow/block specific numbers
5. **Emergency Contacts**: Auto-notify family members on fraud detection
6. **Offline Mode**: Basic rule-based detection without internet
7. **Call Blocking**: Automatically reject high-risk calls
8. **Community Database**: Share fraud patterns anonymously

## Development Guidelines

### Code Style
- **Flutter**: Follow official Dart style guide
- **Kotlin**: Follow Kotlin coding conventions
- **Python**: PEP 8

### Comments
- All functions have docstrings
- Complex logic is explained inline
- Senior-developer-friendly (easy to read)

### Error Handling
- All API calls wrapped in try-catch
- User-friendly error messages
- Fallback behavior on failures

### Testing
- Manual testing on real devices
- Test with various fraud scenarios
- Test with different phone numbers
- Test permission flows

## Deployment

### Flutter App
1. Build release APK: `flutter build apk --release`
2. Sign with production keystore (for Play Store)
3. Upload to Google Play Store or distribute directly

### Backend
1. Deploy to cloud (AWS, Google Cloud, Azure)
2. Set up HTTPS with SSL certificate
3. Configure environment variables
4. Set up monitoring and logging
5. Implement rate limiting
6. Add authentication (if needed)

## Monitoring

- **Flutter**: Use Firebase Crashlytics or Sentry
- **Backend**: Use logging (Python logging module)
- **API Usage**: Monitor OpenAI API usage dashboard
- **User Metrics**: Track fraud detection accuracy

## Legal Considerations

⚠️ **Important**: Call recording laws vary by region
- In India: Generally legal for personal use with consent
- Users must be informed about call recording
- This app is for personal protection, not surveillance
- Consult legal counsel before deploying

## License

This is an MVP for demonstration purposes. Adapt for your specific use case.
