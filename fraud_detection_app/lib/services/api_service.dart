import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/call_record.dart';

/// Service for communicating with backend API
class ApiService {
  // IMPORTANT: Update this URL to your actual backend URL
  // For local testing: http://10.0.2.2:8001/api (Android emulator)
  // For device testing: http://YOUR_COMPUTER_IP:8001/api
  static const String baseUrl = 'http://10.0.2.2:8001/api';

  /// Analyze call audio for fraud
  /// 
  /// Sends audio file to backend, which uses AI to:
  /// 1. Transcribe audio (Whisper)
  /// 2. Analyze for fraud patterns (GPT-4)
  /// 3. Return structured result
  Future<CallRecord?> analyzeCall({
    required String audioFilePath,
    required String phoneNumber,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze-call'),
      );

      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFilePath),
      );

      // Add phone number
      request.fields['phone_number'] = phoneNumber;

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse response
        final data = jsonDecode(response.body);
        return CallRecord.fromJson(data);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  /// Get call history from backend
  Future<List<CallRecord>> getCallHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/call-history'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CallRecord.fromJson(json)).toList();
      } else {
        print('API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error: $e');
      return [];
    }
  }

  /// Test backend connectivity
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
