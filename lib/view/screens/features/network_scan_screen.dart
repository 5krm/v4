import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/network_scan_controller.dart';
import '../../../model/network_scan_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_widget.dart';

class NetworkScanScreen extends StatelessWidget {
  const NetworkScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NetworkScanController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Security Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentScan.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(controller),
                const SizedBox(height: 16),
                _buildScanControls(controller),
                const SizedBox(height: 16),
                _buildScanSettings(controller),
                const SizedBox(height: 16),
                _buildNetworkInfo(controller),
                const SizedBox(height: 16),
                _buildLastScanResults(controller),
                const SizedBox(height: 16),
                _buildScanHistory(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(NetworkScanController controller) {
    return Obx(() {
      final isScanning = controller.isScanning.value;
      final currentScan = controller.currentScan.value;

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isScanning ? Icons.security : Icons.shield,
                    color: isScanning ? Colors.orange : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isScanning
                        ? 'Scanning Network...'
                        : 'Network Scanner Ready',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isScanning) ...[
                const SizedBox(height: 16),
                // Progress indicator
                LinearProgressIndicator(
                  value: controller.scanProgress.value,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scanning... ${(controller.scanProgress.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Start Scan',
                        onPressed: controller.startScan,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Stop Scan',
                        onPressed: controller.isScanning.value
                            ? controller.stopScan
                            : null,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (currentScan != null) ...[
                Text(
                  'Scan Type: ${currentScan.scanType}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Started: ${currentScan.formattedStartTime}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScanControls(NetworkScanController controller) {
    return Obx(() {
      final canStart = controller.canStartScan;
      final canStop = controller.canStopScan;

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Controls',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Start Scan',
                      onPressed: canStart ? () => controller.startScan() : null,
                      color: Colors.green,
                      icon: Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Stop Scan',
                      onPressed: canStop ? () => controller.stopScan() : null,
                      color: Colors.red,
                      icon: Icons.stop,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScanSettings(NetworkScanController controller) {
    return Obx(() {
      final settings = controller.scanSettings.value;

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Scan Types
              const Text(
                'Scan Types:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'port_scan',
                  'vulnerability_scan',
                  'device_discovery',
                  'security_audit',
                ].map((type) {
                  final isSelected = settings.scanTypes.contains(type);
                  return FilterChip(
                    label: Text(_formatScanType(type)),
                    selected: isSelected,
                    onSelected: (selected) => controller.toggleScanType(type),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Scan Intensity
              const Text(
                'Scan Intensity:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'light',
                    label: Text('Light'),
                    icon: Icon(Icons.speed, size: 16),
                  ),
                  ButtonSegment(
                    value: 'normal',
                    label: Text('Normal'),
                    icon: Icon(Icons.balance, size: 16),
                  ),
                  ButtonSegment(
                    value: 'intensive',
                    label: Text('Intensive'),
                    icon: Icon(Icons.security, size: 16),
                  ),
                ],
                selected: {settings.intensity},
                onSelectionChanged: (Set<String> selection) {
                  controller.setScanIntensity(selection.first);
                },
              ),

              const SizedBox(height: 16),

              // Auto Scan Toggle
              SwitchListTile(
                title: const Text('Auto Scan'),
                subtitle: const Text('Automatically scan network periodically'),
                value: settings.autoScan,
                onChanged: (value) => controller.toggleAutoScan(value),
                contentPadding: EdgeInsets.zero,
              ),

              if (settings.autoScan) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: settings.scanSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Scan Schedule',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'hourly', child: Text('Every Hour')),
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setScanSchedule(value);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNetworkInfo(NetworkScanController controller) {
    return Obx(() {
      final networkInfo = controller.networkInfo.value;

      if (networkInfo == null) {
        return const SizedBox.shrink();
      }

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Network Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                  'Network Name', networkInfo.networkName ?? 'Unknown'),
              _buildInfoRow('IP Address', networkInfo.localIp ?? 'Unknown'),
              _buildInfoRow('Subnet', networkInfo.subnetMask ?? 'Unknown'),
              _buildInfoRow('Gateway', networkInfo.gatewayIp ?? 'Unknown'),
              _buildInfoRow(
                  'DNS Servers', networkInfo.dnsServers.join(', ')),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLastScanResults(NetworkScanController controller) {
    return Obx(() {
      final lastScan = controller.lastScanResult.value;

      if (lastScan == null || !lastScan.isCompleted) {
        return const SizedBox.shrink();
      }

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Last Scan Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Security Score
              Row(
                children: [
                  const Text('Security Score: '),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSecurityScoreColor(
                          lastScan.securityScore.toDouble()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lastScan.securityScore}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.getSecurityScoreDescription(
                        lastScan.securityScore.toDouble()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Scan Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Devices',
                    lastScan.devicesFound.toString(),
                    Icons.devices,
                  ),
                  _buildSummaryItem(
                    'Threats',
                    lastScan.threatsFound.toString(),
                    Icons.warning,
                  ),
                  _buildSummaryItem(
                    'Duration',
                    controller.getFormattedDuration(lastScan.scanDuration),
                    Icons.timer,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // View Details Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'View Detailed Results',
                  onPressed: () => _showScanDetails(lastScan),
                  icon: Icons.visibility,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScanHistory(NetworkScanController controller) {
    return Obx(() {
      final history = controller.scanHistory;

      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.getHistory(limit: 20),
                    child: const Text('Load More'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (history.isEmpty) ...[
                const SizedBox(height: 32),
                EmptyStateWidget(
                  title: 'No Scan History',
                  message:
                      'Your network scan history will appear here once you complete your first scan.',
                  icon: Icons.history,
                ),
              ] else ...[
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final scan = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('${scan.scanType} Scan'),
                        subtitle: Text(
                          '${scan.formattedStartTime} • ${scan.statusDisplay}',
                          style: TextStyle(
                            color: scan.isCompleted
                                ? Colors.green
                                : scan.isFailed
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                        trailing: scan.isCompleted
                            ? Text('${scan.threatsFound} threats')
                            : null,
                        onTap: () => _showScanDetails(scan),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getSecurityScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getThreatLevelColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatScanType(String scanType) {
    return scanType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _showScanDetails(NetworkScan scan) {
    Get.dialog(
      AlertDialog(
        title: Text('Scan Details - ${scan.statusDisplay}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Scan Type', _formatScanType(scan.scanType)),
              _buildInfoRow('Status', scan.statusDisplay),
              _buildInfoRow('Progress', '${scan.progress}%'),
              _buildInfoRow(
                  'Security Score', '${scan.securityScore.toInt()}/100'),
              _buildInfoRow('Devices Found', scan.devicesFound.toString()),
              _buildInfoRow('Threats Found', scan.threatsFound.toString()),
              _buildInfoRow('Started', scan.formattedStartTime),
              if (scan.completedAt != null)
                _buildInfoRow('Completed', scan.formattedCompletedTime),
              _buildInfoRow('Duration', scan.duration),
              if (scan.devicesList.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Devices Found (${scan.devicesList.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scan.devicesList.length,
                  itemBuilder: (context, index) {
                    final device = scan.devicesList[index];
                    return ListTile(
                      title: Text(device.displayName),
                      subtitle: Text(device.ip),
                      trailing: Text(
                        device.deviceType,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
              if (scan.threats.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Security Threats (${scan.threats.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scan.threats.length,
                  itemBuilder: (context, index) {
                    final threat = scan.threats[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(threat.type),
                        subtitle: Text(threat.description),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getThreatLevelColor(threat.severity),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            threat.severity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
