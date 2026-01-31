package com.fraud.detection

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity - Entry point for the Flutter app
 * Handles platform channel communication between Flutter and Kotlin
 */
class MainActivity: FlutterActivity() {
    private val CHANNEL = "call_fraud/native"
    private val PERMISSION_REQUEST_CODE = 1001
    
    private var methodChannel: MethodChannel? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for Flutter-Kotlin communication
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCallMonitoring" -> {
                    startCallMonitoring(result)
                }
                "stopCallMonitoring" -> {
                    stopCallMonitoring(result)
                }
                "isMonitoring" -> {
                    result.success(isServiceRunning())
                }
                "requestPermissions" -> {
                    pendingResult = result
                    requestNecessaryPermissions()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Start the call monitoring service
     */
    private fun startCallMonitoring(result: MethodChannel.Result) {
        // Check if we have necessary permissions
        if (!hasRequiredPermissions()) {
            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
            return
        }

        // Start the foreground service
        val intent = Intent(this, CallMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        result.success(true)
    }

    /**
     * Stop the call monitoring service
     */
    private fun stopCallMonitoring(result: MethodChannel.Result) {
        val intent = Intent(this, CallMonitorService::class.java)
        stopService(intent)
        result.success(true)
    }

    /**
     * Check if service is currently running
     */
    private fun isServiceRunning(): Boolean {
        // Simple check - in production, you might want a more robust method
        val prefs = getSharedPreferences("fraud_detection", Context.MODE_PRIVATE)
        return prefs.getBoolean("service_running", false)
    }

    /**
     * Request necessary permissions from user
     */
    private fun requestNecessaryPermissions() {
        val permissions = mutableListOf<String>()
        
        // Phone state permission (to detect calls)
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.READ_PHONE_STATE)
        }
        
        // Audio recording permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.RECORD_AUDIO)
        }
        
        // Read call log (optional, for phone number)
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.READ_CALL_LOG)
        }

        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this, 
                permissions.toTypedArray(), 
                PERMISSION_REQUEST_CODE
            )
        } else {
            // All permissions already granted
            pendingResult?.success(true)
            pendingResult = null
        }
    }

    /**
     * Check if all required permissions are granted
     */
    private fun hasRequiredPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) 
                == PackageManager.PERMISSION_GRANTED &&
               ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
                == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Handle permission request result
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.isNotEmpty() && 
                            grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            
            pendingResult?.success(allGranted)
            pendingResult = null
        }
    }
}
