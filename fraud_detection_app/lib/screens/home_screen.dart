import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/call_record.dart';
import '../services/call_service.dart';
import '../widgets/risk_badge.dart';

/// Home screen showing last call status
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CallService _callService = CallService();
  CallRecord? _lastCallRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastCall();
  }

  /// Load the most recent call record
  Future<void> _loadLastCall() async {
    setState(() {
      _isLoading = true;
    });

    final records = await _callService.getLocalCallRecords();
    
    setState(() {
      _lastCallRecord = records.isNotEmpty ? records.first : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fraud Detection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLastCall,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Last Call Status',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Last call result or empty state
                    if (_lastCallRecord != null) ..[
                      RiskBadge(record: _lastCallRecord!),
                      const SizedBox(height: 20),
                      
                      // Phone number and timestamp
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Phone Number',
                        value: _lastCallRecord!.phoneNumber,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: 'Time',
                        value: _formatDateTime(_lastCallRecord!.timestamp),
                      ),
                    ] else ..[
                      // Empty state
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone_disabled,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No calls analyzed yet',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enable monitoring in Settings to start',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Information card
                    _buildHelpCard(),
                  ],
                ),
              ),
      ),
    );
  }

  /// Build info card widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blue[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build help/information card
  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 32,
            color: Colors.amber[800],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The app monitors your calls and uses AI to detect fraud. After each call, you\'ll see if it was safe, suspicious, or fraud.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format datetime for display
  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
