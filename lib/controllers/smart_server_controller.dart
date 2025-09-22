import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/smart_server_model.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class SmartServerController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger('SmartServerController');

  // Observables
  final smartServerSettings = SmartServerSettings().obs;
  final serverRecommendations = <ServerRecommendation>[].obs;
  final serverAnalytics = ServerAnalytics().obs;
  final feedbackHistory = <ServerFeedback>[].obs;
  
  // Loading states
  final isLoadingSettings = false.obs;
  final isLoadingRecommendations = false.obs;
  final isLoadingAnalytics = false.obs;
  final isLoadingFeedback = false.obs;
  final isUpdatingSettings = false.obs;
  final isSubmittingFeedback = false.obs;
  
  // Error states
  final settingsError = ''.obs;
  final recommendationsError = ''.obs;
  final analyticsError = ''.obs;
  final feedbackError = ''.obs;
  
  // UI states
  final selectedOptimizationMode = 'balanced'.obs;
  final autoFailoverEnabled = true.obs;
  final learningEnabled = true.obs;
  final showAdvancedSettings = false.obs;
  final currentRecommendation = Rxn<ServerRecommendation>();
  
  // Performance tracking
  final connectionMetrics = <String, dynamic>{}.obs;
  final performanceHistory = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSmartServer();
  }

  Future<void> _initializeSmartServer() async {
    await loadSettings();
    await loadRecommendations();
    await loadAnalytics();
  }

  // Settings Management
  Future<void> loadSettings() async {
    try {
      isLoadingSettings.value = true;
      settingsError.value = '';
      
      final response = await ApiService.get('/smart-server/settings');
      
      if (response['success']) {
        smartServerSettings.value = SmartServerSettings.fromJson(response['data']);
        selectedOptimizationMode.value = smartServerSettings.value.optimizationMode;
        autoFailoverEnabled.value = smartServerSettings.value.autoFailover;
        learningEnabled.value = smartServerSettings.value.learningEnabled;
        _logger.info('Smart server settings loaded successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to load settings');
      }
    } catch (e) {
      settingsError.value = e.toString();
      _logger.error('Failed to load smart server settings: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      isUpdatingSettings.value = true;
      settingsError.value = '';
      
      final response = await ApiService.put('/smart-server/settings', settings);
      
      if (response['success']) {
        smartServerSettings.value = SmartServerSettings.fromJson(response['data']);
        Get.snackbar(
          'Success',
          'Smart server settings updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _logger.info('Smart server settings updated successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to update settings');
      }
    } catch (e) {
      settingsError.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update settings: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.error('Failed to update smart server settings: $e');
    } finally {
      isUpdatingSettings.value = false;
    }
  }

  // Server Recommendations
  Future<void> loadRecommendations() async {
    try {
      isLoadingRecommendations.value = true;
      recommendationsError.value = '';
      
      final response = await ApiService.get('/smart-server/recommendations');
      
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        serverRecommendations.value = data
            .map((json) => ServerRecommendation.fromJson(json))
            .toList();
        
        if (serverRecommendations.isNotEmpty) {
          currentRecommendation.value = serverRecommendations.first;
        }
        
        _logger.info('Server recommendations loaded: ${serverRecommendations.length} servers');
      } else {
        throw Exception(response['message'] ?? 'Failed to load recommendations');
      }
    } catch (e) {
      recommendationsError.value = e.toString();
      _logger.error('Failed to load server recommendations: $e');
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  Future<void> recordFeedback(String serverId, Map<String, dynamic> feedback) async {
    try {
      isSubmittingFeedback.value = true;
      feedbackError.value = '';
      
      final response = await ApiService.post('/smart-server/feedback', {
        'server_id': serverId,
        ...feedback,
      });
      
      if (response['success']) {
        Get.snackbar(
          'Thank You',
          'Your feedback has been recorded and will help improve recommendations',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Reload recommendations to get updated scores
        await loadRecommendations();
        await loadAnalytics();
        
        _logger.info('Server feedback recorded successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to record feedback');
      }
    } catch (e) {
      feedbackError.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to record feedback: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.error('Failed to record server feedback: $e');
    } finally {
      isSubmittingFeedback.value = false;
    }
  }

  // Analytics
  Future<void> loadAnalytics() async {
    try {
      isLoadingAnalytics.value = true;
      analyticsError.value = '';
      
      final response = await ApiService.get('/smart-server/analytics');
      
      if (response['success']) {
        serverAnalytics.value = ServerAnalytics.fromJson(response['data']);
        _logger.info('Server analytics loaded successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to load analytics');
      }
    } catch (e) {
      analyticsError.value = e.toString();
      _logger.error('Failed to load server analytics: $e');
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  // Failover Management
  Future<void> triggerFailover() async {
    try {
      final response = await ApiService.post('/smart-server/failover', {});
      
      if (response['success']) {
        Get.snackbar(
          'Failover Triggered',
          'Switching to backup server...',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        
        // Reload recommendations
        await loadRecommendations();
        
        _logger.info('Server failover triggered successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to trigger failover');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger failover: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.error('Failed to trigger server failover: $e');
    }
  }

  // Learning Data Management
  Future<void> resetLearningData() async {
    try {
      final response = await ApiService.delete('/smart-server/learning');
      
      if (response['success']) {
        Get.snackbar(
          'Learning Data Reset',
          'AI learning data has been cleared',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        
        // Reload everything
        await _initializeSmartServer();
        
        _logger.info('Learning data reset successfully');
      } else {
        throw Exception(response['message'] ?? 'Failed to reset learning data');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset learning data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.error('Failed to reset learning data: $e');
    }
  }

  // UI Helper Methods
  void toggleOptimizationMode(String mode) {
    selectedOptimizationMode.value = mode;
    updateSettings({'optimization_mode': mode});
  }

  void toggleAutoFailover(bool enabled) {
    autoFailoverEnabled.value = enabled;
    updateSettings({'auto_failover': enabled});
  }

  void toggleLearning(bool enabled) {
    learningEnabled.value = enabled;
    updateSettings({'learning_enabled': enabled});
  }

  void toggleAdvancedSettings() {
    showAdvancedSettings.value = !showAdvancedSettings.value;
  }

  // Performance Tracking
  void updateConnectionMetrics(Map<String, dynamic> metrics) {
    connectionMetrics.value = metrics;
    performanceHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': Map<String, dynamic>.from(metrics),
    });
    
    // Keep only last 100 entries
    if (performanceHistory.length > 100) {
      performanceHistory.removeAt(0);
    }
  }

  // Utility Methods
  String getOptimizationModeDescription(String mode) {
    switch (mode) {
      case 'speed':
        return 'Prioritizes fastest connection speeds';
      case 'security':
        return 'Focuses on maximum security and encryption';
      case 'balanced':
        return 'Balances speed, security, and reliability';
      case 'reliability':
        return 'Emphasizes stable and consistent connections';
      default:
        return 'Unknown optimization mode';
    }
  }

  String formatRecommendationScore(double score) {
    return '${(score * 100).toStringAsFixed(1)}%';
  }

  Color getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  // Data Refresh
  Future<void> refreshAllData() async {
    await Future.wait([
      loadSettings(),
      loadRecommendations(),
      loadAnalytics(),
    ]);
  }

  @override
  void onClose() {
    super.onClose();
    _logger.info('SmartServerController disposed');
  }
}