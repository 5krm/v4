import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connection_manager.dart';
import '../utils/my_color.dart';

/// Widget to display current connection status and allow manual URL switching
class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  final ConnectionManager _connectionManager = ConnectionManager();
  ConnectionStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _status = _connectionManager.getConnectionStatus();
    });
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _connectionManager.checkAndSwitchIfNeeded();
      _updateStatus();
      
      Get.snackbar(
        'Connection Check',
        'Connection status updated',
        backgroundColor: MyColor.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check connection: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchToFallback() {
    _connectionManager.forceUseFallback();
    _updateStatus();
    Get.snackbar(
      'URL Switched',
      'Switched to fallback URL',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _switchToPrimary() {
    _connectionManager.forceUsePrimary();
    _updateStatus();
    Get.snackbar(
      'URL Switched',
      'Switched to primary URL',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _status!.isUsingFallback ? Icons.warning : Icons.check_circle,
                  color: _status!.isUsingFallback ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connection Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Current URL info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status!.isUsingFallback 
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status!.isUsingFallback 
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status!.isUsingFallback ? 'Using Fallback URL' : 'Using Primary URL',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _status!.isUsingFallback ? Colors.orange[700] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _status!.currentUrl,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkConnection,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(_isLoading ? 'Checking...' : 'Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                if (!_status!.isUsingFallback)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _switchToFallback,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Use Fallback'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                
                if (_status!.isUsingFallback)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _switchToPrimary,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Use Primary'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
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