import 'package:flutter/material.dart';
import '../models/call_record.dart';

/// Widget to display risk level with color coding
class RiskBadge extends StatelessWidget {
  final CallRecord record;
  final bool showDetails;

  const RiskBadge({
    super.key,
    required this.record,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    String displayText;

    // Color coding: Green = Safe, Orange = Suspicious, Red = Fraud
    switch (record.riskCategory) {
      case 'SAFE':
        backgroundColor = const Color(0xFF4CAF50); // Green
        icon = Icons.check_circle;
        displayText = 'SAFE';
        break;
      case 'SUSPICIOUS':
        backgroundColor = const Color(0xFFFF9800); // Orange
        icon = Icons.warning;
        displayText = 'SUSPICIOUS';
        break;
      case 'FRAUD':
        backgroundColor = const Color(0xFFF44336); // Red
        icon = Icons.dangerous;
        displayText = 'FRAUD';
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.help;
        displayText = 'UNKNOWN';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large icon
          Icon(
            icon,
            size: 80,
            color: textColor,
          ),
          const SizedBox(height: 16),
          
          // Risk level text
          Text(
            displayText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          
          if (showDetails) ..[
            const SizedBox(height: 12),
            
            // Fraud score
            Text(
              'Risk Score: ${record.fraudScore}%',
              style: TextStyle(
                fontSize: 20,
                color: textColor.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reason
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record.reason,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
