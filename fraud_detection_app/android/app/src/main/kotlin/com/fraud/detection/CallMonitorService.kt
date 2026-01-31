package com.fraud.detection

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import androidx.core.app.NotificationCompat
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

/**
 * Foreground Service for Call Monitoring
 * 
 * This service runs in the background and:
 * 1. Detects incoming phone calls
 * 2. Records call audio when call is answered
 * 3. Saves recording to local storage
 * 4. Notifies Flutter app when call ends
 * 
 * IMPORTANT NOTES:
 * - Call recording has legal restrictions in many regions
 * - This is a simplified MVP implementation
 * - Production apps need proper consent mechanisms
 * - Some Android versions/devices may block call recording
 */
class CallMonitorService : Service() {
    
    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    private var mediaRecorder: MediaRecorder? = null
    
    private var isRecording = false
    private var currentCallFile: File? = null
    private var callStartTime: Long = 0
    
    companion object {
        private const val CHANNEL_ID = "FraudDetectionChannel"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        
        // Mark service as running
        getSharedPreferences("fraud_detection", Context.MODE_PRIVATE)
            .edit()
            .putBoolean("service_running", true)
            .apply()
        
        // Create notification channel (required for foreground service)
        createNotificationChannel()
        
        // Start as foreground service
        startForeground(NOTIFICATION_ID, createNotification())
        
        // Initialize telephony manager and listener
        setupCallMonitoring()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY // Restart if killed
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null // Not a bound service
    }

    override fun onDestroy() {
        super.onDestroy()
        
        // Stop recording if active
        stopRecording()
        
        // Unregister phone state listener
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        }
        
        // Mark service as stopped
        getSharedPreferences("fraud_detection", Context.MODE_PRIVATE)
            .edit()
            .putBoolean("service_running", false)
            .apply()
    }

    /**
     * Set up phone call monitoring
     */
    private fun setupCallMonitoring() {
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        
        phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                super.onCallStateChanged(state, phoneNumber)
                
                when (state) {
                    TelephonyManager.CALL_STATE_RINGING -> {
                        // Incoming call detected
                        onIncomingCall(phoneNumber)
                    }
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        // Call answered (or outgoing call started)
                        onCallAnswered(phoneNumber)
                    }
                    TelephonyManager.CALL_STATE_IDLE -> {
                        // Call ended
                        onCallEnded(phoneNumber)
                    }
                }
            }
        }
        
        // Register listener
        @Suppress("DEPRECATION")
        telephonyManager?.listen(
            phoneStateListener, 
            PhoneStateListener.LISTEN_CALL_STATE
        )
    }

    /**
     * Called when incoming call is detected
     */
    private fun onIncomingCall(phoneNumber: String?) {
        // Log for debugging
        android.util.Log.d("CallMonitor", "Incoming call from: ${phoneNumber ?: "Unknown"}")
        
        // Update notification
        val notification = createNotification("Incoming call detected")
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    /**
     * Called when call is answered
     */
    private fun onCallAnswered(phoneNumber: String?) {
        android.util.Log.d("CallMonitor", "Call answered: ${phoneNumber ?: "Unknown"}")
        
        // Start recording
        startRecording(phoneNumber)
        
        // Update notification
        val notification = createNotification("Recording call...")
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    /**
     * Called when call ends
     */
    private fun onCallEnded(phoneNumber: String?) {
        android.util.Log.d("CallMonitor", "Call ended: ${phoneNumber ?: "Unknown"}")
        
        // Stop recording
        stopRecording()
        
        // Notify Flutter app if we have a recording
        if (currentCallFile != null && currentCallFile!!.exists()) {
            notifyFlutterApp(currentCallFile!!.absolutePath, phoneNumber ?: "Unknown")
        }
        
        // Reset state
        currentCallFile = null
        callStartTime = 0
        
        // Update notification
        val notification = createNotification("Monitoring calls")
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    /**
     * Start recording call audio
     * 
     * NOTE: Call recording may not work on all devices/Android versions
     * This is a limitation of the Android platform, not this code
     */
    private fun startRecording(phoneNumber: String?) {
        try {
            // Create file for recording
            val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val fileName = "call_${timestamp}.m4a"
            val directory = getExternalFilesDir(null)
            currentCallFile = File(directory, fileName)
            
            // Initialize MediaRecorder
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            
            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(currentCallFile!!.absolutePath)
                
                prepare()
                start()
                
                isRecording = true
                callStartTime = System.currentTimeMillis()
                
                android.util.Log.d("CallMonitor", "Recording started: ${currentCallFile!!.absolutePath}")
            }
        } catch (e: Exception) {
            android.util.Log.e("CallMonitor", "Failed to start recording: ${e.message}")
            e.printStackTrace()
            
            // Clean up
            mediaRecorder?.release()
            mediaRecorder = null
            isRecording = false
            currentCallFile?.delete()
            currentCallFile = null
        }
    }

    /**
     * Stop recording call audio
     */
    private fun stopRecording() {
        if (isRecording) {
            try {
                mediaRecorder?.stop()
                android.util.Log.d("CallMonitor", "Recording stopped")
            } catch (e: Exception) {
                android.util.Log.e("CallMonitor", "Error stopping recording: ${e.message}")
            } finally {
                mediaRecorder?.release()
                mediaRecorder = null
                isRecording = false
            }
        }
    }

    /**
     * Notify Flutter app that call has ended and recording is available
     * 
     * NOTE: In this MVP, we save the file path to SharedPreferences
     * Flutter app will check this periodically or on app resume
     */
    private fun notifyFlutterApp(audioFilePath: String, phoneNumber: String) {
        // Save to SharedPreferences for Flutter to pick up
        val prefs = getSharedPreferences("fraud_detection", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("last_call_audio", audioFilePath)
            .putString("last_call_number", phoneNumber)
            .putLong("last_call_timestamp", System.currentTimeMillis())
            .apply()
        
        android.util.Log.d("CallMonitor", "Saved call data for Flutter app")
        
        // TODO: In a more sophisticated implementation, you could:
        // 1. Use EventChannel to push events to Flutter
        // 2. Send a local notification to open the app
        // 3. Use WorkManager to trigger analysis immediately
    }

    /**
     * Create notification channel (required for Android O+)
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Call Monitoring",
                NotificationManager.IMPORTANCE_LOW // Low importance = no sound
            ).apply {
                description = "Monitors calls for fraud detection"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Create notification for foreground service
     */
    private fun createNotification(message: String = "Monitoring calls"): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Fraud Detection Active")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_menu_call) // Using system icon for simplicity
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true) // Cannot be dismissed
            .build()
    }
}
