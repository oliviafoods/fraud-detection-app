/// Data model for a call record
class CallRecord {
  final String id;
  final String phoneNumber;
  final DateTime timestamp;
  final String riskCategory; // SAFE, SUSPICIOUS, FRAUD
  final int fraudScore; // 0-100
  final String reason;
  final String? transcript;

  CallRecord({
    required this.id,
    required this.phoneNumber,
    required this.timestamp,
    required this.riskCategory,
    required this.fraudScore,
    required this.reason,
    this.transcript,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'timestamp': timestamp.toIso8601String(),
      'riskCategory': riskCategory,
      'fraudScore': fraudScore,
      'reason': reason,
      'transcript': transcript,
    };
  }

  /// Create from JSON
  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      id: json['id'],
      phoneNumber: json['phoneNumber'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp']),
      riskCategory: json['riskCategory'],
      fraudScore: json['fraudScore'],
      reason: json['reason'],
      transcript: json['transcript'],
    );
  }

  /// Get color based on risk category
  String getColorHex() {
    switch (riskCategory) {
      case 'SAFE':
        return '#4CAF50'; // Green
      case 'SUSPICIOUS':
        return '#FF9800'; // Orange
      case 'FRAUD':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
}
