import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/multi_hop_model.dart';
import '../services/api_service.dart';

class MultiHopController extends GetxController {
  // Observables
  final _isLoading = false.obs;
  final _isConnecting = false.obs;
  final _isConnected = false.obs;
  final _connections = <MultiHopConnection>[].obs;
  final _activeConnection = Rxn<MultiHopConnection>();
  final _connectionLogs = <MultiHopLog>[].obs;
  final _performanceMetrics = Rxn<MultiHopPerformanceMetrics>();
  final _errorMessage = ''.obs;
  final _showAdvancedSettings = false.obs;
  final _selectedProtocol = 'auto'.obs;
  final _selectedEncryption = 'high'.obs;
  final _selectedRouting = 'optimal'.obs;
  final _autoOptimize = true.obs;
  final _failoverEnabled = true.obs;
  final _maxHops = 3.obs;
  final _connectionTimeout = 30.obs;
  final _retryAttempts = 3.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isConnecting => _isConnecting.value;
  bool get isConnected => _isConnected.value;
  List<MultiHopConnection> get connections => _connections;
  MultiHopConnection? get activeConnection => _activeConnection.value;
  List<MultiHopLog> get connectionLogs => _connectionLogs;
  MultiHopPerformanceMetrics? get performanceMetrics => _performanceMetrics.value;
  String get errorMessage => _errorMessage.value;
  bool get showAdvancedSettings => _showAdvancedSettings.value;
  String get selectedProtocol => _selectedProtocol.value;
  String get selectedEncryption => _selectedEncryption.value;
  String get selectedRouting => _selectedRouting.value;
  bool get autoOptimize => _autoOptimize.value;
  bool get failoverEnabled => _failoverEnabled.value;
  int get maxHops => _maxHops.value;
  int get connectionTimeout => _connectionTimeout.value;
  int get retryAttempts => _retryAttempts.value;

  // Available options
  final List<String> protocols = ['auto', 'openvpn', 'ikev2', 'wireguard', 'sstp'];
  final List<String> encryptionLevels = ['medium', 'high', 'maximum'];
  final List<String> routingStrategies = ['fastest', 'optimal', 'secure', 'balanced'];
  final List<String> performancePriorities = ['speed', 'balanced', 'security', 'stability'];
  final List<String> securityLevels = ['medium', 'high', 'maximum'];

  @override
  void onInit() {
    super.onInit();
    _initializeMultiHop();
  }

  // Initialization
  Future<void> _initializeMultiHop() async {
    try {
      _isLoading.value = true;
      await _loadConnections();
      await _loadActiveConnection();
      await _loadPerformanceMetrics();
      _startPerformanceMonitoring();
    } catch (e) {
      _errorMessage.value = 'Failed to initialize Multi-Hop: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Connection Management
  Future<void> _loadConnections() async {
    try {
      final response = await ApiService.get('/multi-hop/connections');
      if (response['success']) {
        _connections.value = (response['data'] as List)
            .map((json) => MultiHopConnection.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading connections: $e');
    }
  }

  Future<void> _loadActiveConnection() async {
    try {
      final response = await ApiService.get('/multi-hop/active-connection');
      if (response['success'] && response['data'] != null) {
        _activeConnection.value = MultiHopConnection.fromJson(response['data']);
        _isConnected.value = _activeConnection.value?.isActive ?? false;
      }
    } catch (e) {
      print('Error loading active connection: $e');
    }
  }

  Future<void> createConnection(String name, List<String> serverIds) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final connectionData = {
        'connection_name': name,
        'server_ids': serverIds,
        'connection_protocol': _selectedProtocol.value,
        'encryption_level': _selectedEncryption.value,
        'routing_strategy': _selectedRouting.value,
        'auto_optimize': _autoOptimize.value,
        'failover_enabled': _failoverEnabled.value,
        'connection_timeout': _connectionTimeout.value,
        'retry_attempts': _retryAttempts.value,
      };

      final response = await ApiService.post('/multi-hop/connections', connectionData);
      
      if (response['success']) {
        await _loadConnections();
        Get.snackbar(
          'Success',
          'Multi-hop connection created successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to create connection';
      }
    } catch (e) {
      _errorMessage.value = 'Error creating connection: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> connectToMultiHop(String connectionId) async {
    try {
      _isConnecting.value = true;
      _errorMessage.value = '';

      final response = await ApiService.post('/multi-hop/connect', {
        'connection_id': connectionId,
      });

      if (response['success']) {
        _isConnected.value = true;
        await _loadActiveConnection();
        await _startConnectionMonitoring();
        
        Get.snackbar(
          'Connected',
          'Multi-hop VPN connection established',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to connect';
      }
    } catch (e) {
      _errorMessage.value = 'Connection error: ${e.toString()}';
    } finally {
      _isConnecting.value = false;
    }
  }

  Future<void> disconnectMultiHop() async {
    try {
      _isConnecting.value = true;
      _errorMessage.value = '';

      final response = await ApiService.post('/multi-hop/disconnect', {});

      if (response['success']) {
        _isConnected.value = false;
        _activeConnection.value = null;
        _stopConnectionMonitoring();
        
        Get.snackbar(
          'Disconnected',
          'Multi-hop VPN connection terminated',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to disconnect';
      }
    } catch (e) {
      _errorMessage.value = 'Disconnection error: ${e.toString()}';
    } finally {
      _isConnecting.value = false;
    }
  }

  Future<void> deleteConnection(String connectionId) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.delete('/multi-hop/connections/$connectionId');
      
      if (response['success']) {
        await _loadConnections();
        Get.snackbar(
          'Deleted',
          'Connection deleted successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to delete connection';
      }
    } catch (e) {
      _errorMessage.value = 'Error deleting connection: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Hop Management
  Future<void> addHopToConnection(String connectionId, String serverId, int order) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.post('/multi-hop/connections/$connectionId/hops', {
        'server_id': serverId,
        'hop_order': order,
      });
      
      if (response['success']) {
        await _loadConnections();
        if (_activeConnection.value?.id == connectionId) {
          await _loadActiveConnection();
        }
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to add hop';
      }
    } catch (e) {
      _errorMessage.value = 'Error adding hop: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeHopFromConnection(String connectionId, String hopId) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.delete('/multi-hop/connections/$connectionId/hops/$hopId');
      
      if (response['success']) {
        await _loadConnections();
        if (_activeConnection.value?.id == connectionId) {
          await _loadActiveConnection();
        }
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to remove hop';
      }
    } catch (e) {
      _errorMessage.value = 'Error removing hop: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reorderHops(String connectionId, List<Map<String, dynamic>> hopOrder) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.put('/multi-hop/connections/$connectionId/reorder', {
        'hop_order': hopOrder,
      });
      
      if (response['success']) {
        await _loadConnections();
        if (_activeConnection.value?.id == connectionId) {
          await _loadActiveConnection();
        }
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to reorder hops';
      }
    } catch (e) {
      _errorMessage.value = 'Error reordering hops: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Performance and Monitoring
  Future<void> _loadPerformanceMetrics() async {
    try {
      final response = await ApiService.get('/multi-hop/performance-metrics');
      if (response['success'] && response['data'] != null) {
        _performanceMetrics.value = MultiHopPerformanceMetrics.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading performance metrics: $e');
    }
  }

  Future<void> _loadConnectionLogs() async {
    try {
      final response = await ApiService.get('/multi-hop/logs');
      if (response['success']) {
        _connectionLogs.value = (response['data'] as List)
            .map((json) => MultiHopLog.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading connection logs: $e');
    }
  }

  void _startPerformanceMonitoring() {
    // Start periodic performance monitoring
    Future.delayed(const Duration(seconds: 5), () {
      if (_isConnected.value) {
        _loadPerformanceMetrics();
        _loadConnectionLogs();
        _startPerformanceMonitoring();
      }
    });
  }

  Future<void> _startConnectionMonitoring() async {
    // Start monitoring connection health
    _monitorConnectionHealth();
  }

  void _stopConnectionMonitoring() {
    // Stop monitoring when disconnected
  }

  Future<void> _monitorConnectionHealth() async {
    if (!_isConnected.value) return;
    
    try {
      final response = await ApiService.get('/multi-hop/health-check');
      if (response['success']) {
        // Update connection health status
        await _loadActiveConnection();
        await _loadPerformanceMetrics();
      }
    } catch (e) {
      print('Health check error: $e');
    }
    
    // Schedule next health check
    Future.delayed(const Duration(seconds: 30), () {
      _monitorConnectionHealth();
    });
  }

  // Optimization and Failover
  Future<void> optimizeRoute() async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.post('/multi-hop/optimize-route', {});
      
      if (response['success']) {
        await _loadActiveConnection();
        await _loadPerformanceMetrics();
        
        Get.snackbar(
          'Optimized',
          'Route has been optimized for better performance',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to optimize route';
      }
    } catch (e) {
      _errorMessage.value = 'Optimization error: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> triggerFailover() async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.post('/multi-hop/failover', {});
      
      if (response['success']) {
        await _loadActiveConnection();
        
        Get.snackbar(
          'Failover',
          'Connection failed over to backup servers',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failover failed';
      }
    } catch (e) {
      _errorMessage.value = 'Failover error: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> testConnection() async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.post('/multi-hop/test-connection', {});
      
      if (response['success']) {
        final testResults = response['data'];
        
        Get.dialog(
          AlertDialog(
            title: const Text('Connection Test Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latency: ${testResults['latency']}ms'),
                Text('Speed: ${testResults['speed']} Mbps'),
                Text('Packet Loss: ${testResults['packet_loss']}%'),
                Text('Security Score: ${testResults['security_score']}/100'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Connection test failed';
      }
    } catch (e) {
      _errorMessage.value = 'Test error: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Settings Management
  Future<void> updateConnectionSettings(String connectionId, Map<String, dynamic> settings) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService.put('/multi-hop/connections/$connectionId/settings', settings);
      
      if (response['success']) {
        await _loadConnections();
        if (_activeConnection.value?.id == connectionId) {
          await _loadActiveConnection();
        }
        
        Get.snackbar(
          'Updated',
          'Connection settings updated successfully',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to update settings';
      }
    } catch (e) {
      _errorMessage.value = 'Settings update error: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // UI State Management
  void toggleAdvancedSettings() {
    _showAdvancedSettings.value = !_showAdvancedSettings.value;
  }

  void setProtocol(String protocol) {
    _selectedProtocol.value = protocol;
  }

  void setEncryption(String encryption) {
    _selectedEncryption.value = encryption;
  }

  void setRouting(String routing) {
    _selectedRouting.value = routing;
  }

  void setAutoOptimize(bool value) {
    _autoOptimize.value = value;
  }

  void setFailoverEnabled(bool value) {
    _failoverEnabled.value = value;
  }

  void setMaxHops(int value) {
    _maxHops.value = value;
  }

  void setConnectionTimeout(int value) {
    _connectionTimeout.value = value;
  }

  void setRetryAttempts(int value) {
    _retryAttempts.value = value;
  }

  void clearError() {
    _errorMessage.value = '';
  }

  // Utility Methods
  String getConnectionStatusText() {
    if (_isConnecting.value) {
      return 'Connecting...';
    } else if (_isConnected.value) {
      return 'Connected via Multi-Hop';
    } else {
      return 'Disconnected';
    }
  }

  Color getConnectionStatusColor() {
    if (_isConnecting.value) {
      return Colors.orange;
    } else if (_isConnected.value) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String getSecurityLevelDescription(String level) {
    switch (level) {
      case 'maximum':
        return 'Maximum security with strongest encryption';
      case 'high':
        return 'High security with strong encryption';
      case 'medium':
        return 'Balanced security and performance';
      default:
        return 'Standard security level';
    }
  }

  String getRoutingStrategyDescription(String strategy) {
    switch (strategy) {
      case 'fastest':
        return 'Prioritizes speed over security';
      case 'secure':
        return 'Prioritizes security over speed';
      case 'balanced':
        return 'Balances speed and security';
      case 'optimal':
        return 'AI-optimized routing for best overall performance';
      default:
        return 'Standard routing strategy';
    }
  }

  double getOverallSecurityScore() {
    if (_activeConnection.value == null) return 0.0;
    
    double score = 0.0;
    
    // Base score from encryption level
    switch (_activeConnection.value!.encryptionLevel) {
      case 'maximum':
        score += 40;
        break;
      case 'high':
        score += 30;
        break;
      case 'medium':
        score += 20;
        break;
    }
    
    // Bonus for multiple hops
    score += (_activeConnection.value!.totalHops * 10).clamp(0, 30);
    
    // Bonus for security level
    switch (_activeConnection.value!.securityLevel) {
      case 'maximum':
        score += 30;
        break;
      case 'high':
        score += 20;
        break;
      case 'medium':
        score += 10;
        break;
    }
    
    return score.clamp(0, 100);
  }

  String formatDataTransferred(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  void onClose() {
    _stopConnectionMonitoring();
    super.onClose();
  }
}