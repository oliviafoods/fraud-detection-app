import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/call_record.dart';

/// Service for interacting with native Kotlin layer
class CallService {
  // Platform channel for communication with Kotlin
  static const platform = MethodChannel('call_fraud/native');

  /// Start call monitoring service
  Future<bool> startMonitoring() async {
    try {
      final bool result = await platform.invokeMethod('startCallMonitoring');
      return result;
    } catch (e) {
      print('Error starting monitoring: $e');
      return false;
    }
  }

  /// Stop call monitoring service
  Future<bool> stopMonitoring() async {
    try {
      final bool result = await platform.invokeMethod('stopCallMonitoring');
      return result;
    } catch (e) {
      print('Error stopping monitoring: $e');
      return false;
    }
  }

  /// Check if monitoring is active
  Future<bool> isMonitoring() async {
    try {
      final bool result = await platform.invokeMethod('isMonitoring');
      return result;
    } catch (e) {
      print('Error checking monitoring status: $e');
      return false;
    }
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      final bool result = await platform.invokeMethod('requestPermissions');
      return result;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Save call record to local storage
  Future<void> saveCallRecord(CallRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing records
    final String? recordsJson = prefs.getString('call_records');
    List<dynamic> records = [];
    
    if (recordsJson != null) {
      records = jsonDecode(recordsJson);
    }
    
    // Add new record
    records.insert(0, record.toJson()); // Add to beginning
    
    // Keep only last 100 records
    if (records.length > 100) {
      records = records.sublist(0, 100);
    }
    
    // Save back
    await prefs.setString('call_records', jsonEncode(records));
  }

  /// Get call records from local storage
  Future<List<CallRecord>> getLocalCallRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('call_records');
    
    if (recordsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> records = jsonDecode(recordsJson);
      return records.map((json) => CallRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error loading records: $e');
      return [];
    }
  }

  /// Clear all local records
  Future<void> clearLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('call_records');
  }
}
