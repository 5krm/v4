import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/connection_status_widget.dart';
import '../utils/my_color.dart';

/// Example screen showing how to integrate connection status
class ConnectionSettingsScreen extends StatefulWidget {
  const ConnectionSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionSettingsScreen> createState() => _ConnectionSettingsScreenState();
}

class _ConnectionSettingsScreenState extends State<ConnectionSettingsScreen> {
  bool _debugMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Settings'),
        backgroundColor: MyColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'API Connection Status',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MyColor.primary,
                ),
              ),
            ),
            
            // Connection Status Widget
            const ConnectionStatusWidget(),
            
            // Information Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: MyColor.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About API Fallback',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This app automatically switches between API servers to ensure reliable connectivity. '
                        'When the primary server is unavailable, the app seamlessly switches to a backup server.',
                        style: TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Features:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem('🔄', 'Automatic server switching'),
                      _buildFeatureItem('⚡', 'Fast failover detection'),
                      _buildFeatureItem('🔙', 'Automatic recovery to primary server'),
                      _buildFeatureItem('🛠️', 'Manual control for testing'),
                    ],
                  ),
                ),
              ),
            ),
            
            // Advanced Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Options',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.bug_report),
                        title: const Text('Debug Mode'),
                        subtitle: const Text('Enable detailed connection logging'),
                        trailing: Switch(
                          value: _debugMode,
                          onChanged: (value) {
                            setState(() {
                              _debugMode = value;
                            });
                            Get.snackbar(
                              'Debug Mode',
                              value ? 'Debug mode enabled' : 'Debug mode disabled',
                              backgroundColor: MyColor.primary,
                              colorText: Colors.white,
                            );
                          },
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.network_check),
                        title: const Text('Connection Test'),
                        subtitle: const Text('Test both primary and fallback servers'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _showConnectionTestDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showConnectionTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Test'),
        content: const Text(
          'This will test connectivity to both the primary and fallback servers. '
          'The test may take a few seconds to complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // You can implement a comprehensive connection test here
              Get.snackbar(
                'Connection Test',
                'Testing connection to all servers...',
                backgroundColor: MyColor.primary,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }
}