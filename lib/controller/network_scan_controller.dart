// ignore_for_file: await_only_futures, annotate_overrides

import 'package:get/get.dart';
import '../api/network_scan_api.dart';
import '../model/network_scan_model.dart';
import '../utils/shared_preference.dart';
import 'dart:async';

class NetworkScanController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isScanning = false.obs;
  final currentScan = Rxn<NetworkScan>();
  final scanHistory = <NetworkScan>[].obs;
  final networkInfo = Rxn<NetworkInfo>();
  final scanSettings = NetworkScanSettings.defaultSettings.obs;
  final scanProgress = 0.0.obs;
  final errorMessage = ''.obs;
  final lastScanResult = Rxn<NetworkScan>();

  // Scan monitoring
  Timer? _scanProgressTimer;
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _scanProgressTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  /// Initialize controller with saved settings and current status
  Future<void> _initializeController() async {
    try {
      await _loadSavedSettings();
      await getStatus();
      await getNetworkInfo();
      _startAutoRefresh();
    } catch (e) {
      _handleError('Failed to initialize network scanner', e);
    }
  }

  /// Load saved scan settings from local storage
  Future<void> _loadSavedSettings() async {
    try {
      final savedSettings =
          await SharedPreference.getString('network_scan_settings');
      if (savedSettings != null) {
        // Parse and apply saved settings
        // For now, using default settings
      }
    } catch (e) {
      // Use default settings if loading fails
    }
  }

  /// Save current scan settings to local storage
  Future<void> _saveScanSettings() async {
    try {
      await SharedPreference.setString(
        'network_scan_settings',
        scanSettings.value.toJson().toString(),
      );
    } catch (e) {
      // Handle save error silently
    }
  }

  /// Get current scan status and latest results
  Future<void> getStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.getStatus();

      if (response.success) {
        if (response.scan != null) {
          currentScan.value = response.scan;

          // Update scanning state based on scan status
          isScanning.value = response.scan!.isActive;
          scanProgress.value = response.scan!.progress / 100.0;

          // If scan is complete, update last result
          if (response.scan!.isCompleted) {
            lastScanResult.value = response.scan;
            _stopProgressMonitoring();
          } else if (response.scan!.isActive) {
            _startProgressMonitoring();
          }
        } else {
          isScanning.value = false;
          scanProgress.value = 0.0;
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to get scan status', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Start a new network security scan
  Future<void> startScan() async {
    try {
      if (isScanning.value) {
        throw Exception('A scan is already in progress');
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.startScan(scanSettings.value);

      if (response.success && response.scan != null) {
        currentScan.value = response.scan;
        isScanning.value = true;
        scanProgress.value = 0.0;

        // Save settings for future use
        await _saveScanSettings();

        // Start monitoring progress
        _startProgressMonitoring();

        Get.snackbar(
          'Scan Started',
          'Network security scan has been initiated',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to start scan', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Stop the current network scan
  Future<void> stopScan() async {
    try {
      if (!isScanning.value || currentScan.value == null) {
        throw Exception('No active scan to stop');
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.stopScan(currentScan.value!.id);

      if (response.success) {
        isScanning.value = false;
        _stopProgressMonitoring();

        // Refresh status to get updated scan info
        await getStatus();

        Get.snackbar(
          'Scan Stopped',
          'Network security scan has been stopped',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to stop scan', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get scan history
  Future<void> getHistory({int limit = 10}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.getHistory(limit: limit);

      if (response.success && response.scans != null) {
        scanHistory.value = response.scans!;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to get scan history', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get detailed scan results
  Future<NetworkScan?> getScanDetails(int scanId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.getScanDetails(scanId);

      if (response.success && response.scan != null) {
        return response.scan;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to get scan details', e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a scan record
  Future<void> deleteScan(int scanId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkScanApi.deleteScan(scanId);

      if (response.success) {
        // Remove from history
        scanHistory.removeWhere((scan) => scan.id == scanId);

        // Clear current scan if it was deleted
        if (currentScan.value?.id == scanId) {
          currentScan.value = null;
          isScanning.value = false;
          _stopProgressMonitoring();
        }

        Get.snackbar(
          'Scan Deleted',
          'Scan record has been deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _handleError('Failed to delete scan', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get network information
  Future<void> getNetworkInfo() async {
    try {
      final response = await NetworkScanApi.getNetworkInfo();

      if (response.success && response.networkInfo != null) {
        networkInfo.value = response.networkInfo;
      }
    } catch (e) {
      // Handle network info error silently
    }
  }

  /// Update scan settings
  void updateScanSettings(NetworkScanSettings newSettings) {
    scanSettings.value = newSettings;
    _saveScanSettings();
  }

  /// Toggle scan type
  void toggleScanType(String scanType) {
    final currentTypes = List<String>.from(scanSettings.value.scanTypes);

    if (currentTypes.contains(scanType)) {
      currentTypes.remove(scanType);
    } else {
      currentTypes.add(scanType);
    }

    scanSettings.value = scanSettings.value.copyWith(scanTypes: currentTypes);
    _saveScanSettings();
  }

  /// Set scan intensity
  void setScanIntensity(String intensity) {
    scanSettings.value = scanSettings.value.copyWith(intensity: intensity);
    _saveScanSettings();
  }

  /// Toggle auto scan
  void toggleAutoScan(bool enabled) {
    scanSettings.value = scanSettings.value.copyWith(autoScan: enabled);
    _saveScanSettings();
  }

  /// Set scan schedule
  void setScanSchedule(String schedule) {
    scanSettings.value = scanSettings.value.copyWith(scanSchedule: schedule);
    _saveScanSettings();
  }

  /// Start monitoring scan progress
  void _startProgressMonitoring() {
    _stopProgressMonitoring();

    _scanProgressTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        if (!isScanning.value) {
          timer.cancel();
          return;
        }

        try {
          await getStatus();
        } catch (e) {
          // Handle error silently during progress monitoring
        }
      },
    );
  }

  /// Stop monitoring scan progress
  void _stopProgressMonitoring() {
    _scanProgressTimer?.cancel();
    _scanProgressTimer = null;
  }

  /// Start auto refresh for status updates
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        if (!isScanning.value) {
          try {
            await getStatus();
          } catch (e) {
            // Handle error silently during auto refresh
          }
        }
      },
    );
  }

  /// Handle errors and update UI state
  void _handleError(String context, dynamic error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    errorMessage.value = message;

    Get.snackbar(
      'Error',
      '$context: $message',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      getStatus(),
      getHistory(),
      getNetworkInfo(),
    ]);
  }

  /// Get security score color based on value
  String getSecurityScoreColor(double score) {
    if (score >= 80) return 'green';
    if (score >= 60) return 'orange';
    return 'red';
  }

  /// Get security score description
  String getSecurityScoreDescription(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Fair';
    if (score >= 60) return 'Poor';
    return 'Critical';
  }

  /// Check if scan can be started
  bool get canStartScan => !isScanning.value && !isLoading.value;

  /// Check if scan can be stopped
  bool get canStopScan => isScanning.value && !isLoading.value;

  /// Get formatted scan duration
  String getFormattedDuration(int? durationSeconds) {
    if (durationSeconds == null) return 'N/A';

    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
