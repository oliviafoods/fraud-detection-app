import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/call_service.dart';
import '../services/api_service.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CallService _callService = CallService();
  final ApiService _apiService = ApiService();
  
  bool _isMonitoring = false;
  String _selectedLanguage = 'English';
  bool _isLoading = true;
  bool _backendConnected = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBackendConnection();
  }

  /// Load current settings
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final isMonitoring = await _callService.isMonitoring();
    final language = prefs.getString('language') ?? 'English';

    setState(() {
      _isMonitoring = isMonitoring;
      _selectedLanguage = language;
      _isLoading = false;
    });
  }

  /// Check backend connectivity
  Future<void> _checkBackendConnection() async {
    final connected = await _apiService.testConnection();
    setState(() {
      _backendConnected = connected;
    });
  }

  /// Toggle monitoring on/off
  Future<void> _toggleMonitoring(bool value) async {
    if (value) {
      // Request permissions first
      final hasPermissions = await _callService.requestPermissions();
      
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permissions required to monitor calls',
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Start monitoring
      final success = await _callService.startMonitoring();
      
      if (success) {
        setState(() {
          _isMonitoring = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Call monitoring enabled',
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Stop monitoring
      final success = await _callService.stopMonitoring();
      
      if (success) {
        setState(() {
          _isMonitoring = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Call monitoring disabled',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }
      }
    }
  }

  /// Change language
  Future<void> _changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    setState(() {
      _selectedLanguage = language;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to $language',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 6),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backend connection status
                  _buildStatusCard(),
                  const SizedBox(height: 24),

                  // Monitoring toggle
                  const Text(
                    'Call Monitoring',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMonitoringCard(),
                  const SizedBox(height: 32),

                  // Language selection
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageCard(),
                  const SizedBox(height: 32),

                  // About section
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAboutCard(),
                ],
              ),
            ),
    );
  }

  /// Build backend status card
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _backendConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _backendConnected ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _backendConnected ? Icons.check_circle : Icons.error,
            size: 32,
            color: _backendConnected ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend Status',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _backendConnected ? 'Connected' : 'Not Connected',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _backendConnected ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _checkBackendConnection,
          ),
        ],
      ),
    );
  }

  /// Build monitoring toggle card
  Widget _buildMonitoringCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enable Monitoring',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor incoming calls for fraud detection',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Transform.scale(
              scale: 1.3,
              child: Switch(
                value: _isMonitoring,
                onChanged: _toggleMonitoring,
                activeColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build language selection card
  Widget _buildLanguageCard() {
    final languages = ['English', 'Hindi'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: languages.map((language) {
          final isSelected = _selectedLanguage == language;
          return InkWell(
            onTap: () => _changeLanguage(language),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : null,
                border: languages.indexOf(language) > 0
                    ? const Border(top: BorderSide(color: Colors.grey, width: 0.5))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 28,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue[800] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build about card
  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fraud Detection App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This app helps senior citizens detect fraudulent phone calls using AI technology.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.security, size: 24, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your privacy is protected. All data is stored locally.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
