import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/multi_hop_controller.dart';
import '../models/multi_hop_model.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class MultiHopScreen extends StatelessWidget {
  const MultiHopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MultiHopController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Hop VPN'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh functionality
              // Currently no public method in controller to refresh data
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatus(controller),
              const SizedBox(height: 20),
              _buildQuickActions(controller),
              const SizedBox(height: 20),
              _buildConnectionsList(controller),
              const SizedBox(height: 20),
              if (controller.activeConnection != null) ...[
                _buildActiveConnectionDetails(controller),
                const SizedBox(height: 20),
                _buildPerformanceMetrics(controller),
                const SizedBox(height: 20),
                _buildConnectionLogs(controller),
              ],
              _buildAdvancedSettings(controller),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConnectionDialog(context, controller),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildConnectionStatus(MultiHopController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.isConnected
                      ? Icons.security
                      : Icons.security_outlined,
                  color: controller.getConnectionStatusColor(),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multi-Hop Status',
                        style: Theme.of(Get.context!).textTheme.titleLarge,
                      ),
                      Text(
                        controller.getConnectionStatusText(),
                        style: TextStyle(
                          color: controller.getConnectionStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.isConnected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'SECURE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            if (controller.activeConnection != null) ...[
              const SizedBox(height: 16),
              _buildConnectionRoute(controller.activeConnection!),
            ],
            if (controller.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: controller.clearError,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionRoute(MultiHopConnection connection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Path:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.route, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  connection.routePath,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${connection.totalHops} hops',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(MultiHopController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text:
                        controller.isConnected ? 'Disconnect' : 'Quick Connect',
                    onPressed: controller.isConnecting
                        ? null
                        : () {
                            if (controller.isConnected) {
                              controller.disconnectMultiHop();
                            } else {
                              _showQuickConnectDialog(Get.context!, controller);
                            }
                          },
                    color: controller.isConnected ? Colors.red : Colors.green,
                    isLoading: controller.isConnecting,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Optimize Route',
                    onPressed: controller.isConnected
                        ? controller.optimizeRoute
                        : null,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Test Connection',
                    onPressed: controller.isConnected
                        ? controller.testConnection
                        : null,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Failover',
                    onPressed:
                        controller.isConnected && controller.failoverEnabled
                            ? controller.triggerFailover
                            : null,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList(MultiHopController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Connections',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showCreateConnectionDialog(Get.context!, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.connections.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No multi-hop connections yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first multi-hop connection for enhanced security',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.connections.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final connection = controller.connections[index];
                  return _buildConnectionItem(connection, controller);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionItem(
      MultiHopConnection connection, MultiHopController controller) {
    final isActive = controller.activeConnection?.id == connection.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: connection.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.connectionName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.blue[700] : null,
                      ),
                    ),
                    Text(
                      '${connection.totalHops} hops • ${connection.routingStrategy}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleConnectionAction(value, connection, controller),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'connect',
                    enabled: !isActive,
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 16),
                        const SizedBox(width: 8),
                        Text('Connect'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 16),
                        const SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            connection.routePath,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricChip('Latency',
                  '${connection.averageLatency.toStringAsFixed(0)}ms'),
              const SizedBox(width: 8),
              _buildMetricChip('Speed',
                  '${connection.averageSpeed.toStringAsFixed(1)} Mbps'),
              const SizedBox(width: 8),
              _buildMetricChip(
                  'Success', '${connection.successRate.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildActiveConnectionDetails(MultiHopController controller) {
    final connection = controller.activeConnection!;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Connection Details',
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Connection Name', connection.connectionName),
            _buildDetailRow(
                'Protocol', connection.connectionProtocol.toUpperCase()),
            _buildDetailRow(
                'Encryption', connection.encryptionLevel.toUpperCase()),
            _buildDetailRow('Routing Strategy', connection.routingStrategy),
            _buildDetailRow(
                'Security Level', connection.securityLevel.toUpperCase()),
            _buildDetailRow('Total Hops', connection.totalHops.toString()),
            if (connection.connectedAt != null)
              _buildDetailRow(
                  'Connected Since', _formatDateTime(connection.connectedAt!)),
            if (connection.connectionDuration != null)
              _buildDetailRow(
                  'Duration',
                  controller.formatDuration(
                      connection.connectionDuration!.inSeconds)),
            _buildDetailRow(
                'Data Transferred',
                controller
                    .formatDataTransferred(connection.totalDataTransferred)),
            const SizedBox(height: 16),
            Text(
              'Hop Details',
              style: Theme.of(Get.context!).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: connection.nodes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final node = connection.nodes[index];
                return _buildHopItem(node, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHopItem(MultiHopNode node, int hopNumber) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: node.statusColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                hopNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.serverLocation,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${node.latency.toStringAsFixed(0)}ms • ${node.healthStatusText}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            node.statusIcon,
            color: node.statusColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(MultiHopController controller) {
    final metrics = controller.performanceMetrics;
    if (metrics == null) return const SizedBox.shrink();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Metrics',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: metrics.performanceGradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: metrics.performanceGradeColor),
                  ),
                  child: Text(
                    'Grade: ${metrics.performanceGrade}',
                    style: TextStyle(
                      color: metrics.performanceGradeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Latency',
                    '${metrics.overallLatency.toStringAsFixed(0)}ms',
                    Icons.speed,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Speed',
                    '${metrics.overallSpeed.toStringAsFixed(1)} Mbps',
                    Icons.flash_on,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Packet Loss',
                    '${metrics.overallPacketLoss.toStringAsFixed(2)}%',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Security Score',
                    '${metrics.securityScore.toStringAsFixed(0)}/100',
                    Icons.security,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreBar('Security', metrics.securityScore, Colors.purple),
            const SizedBox(height: 8),
            _buildScoreBar('Stability', metrics.stabilityScore, Colors.blue),
            const SizedBox(height: 8),
            _buildScoreBar('Efficiency', metrics.efficiencyScore, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${score.toStringAsFixed(0)}/100',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildConnectionLogs(MultiHopController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connection Logs',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () =>
                      _showFullLogsDialog(Get.context!, controller),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.connectionLogs.isEmpty)
              Center(
                child: Text(
                  'No logs available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.connectionLogs.take(5).length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = controller.connectionLogs[index];
                  return _buildLogItem(log);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(MultiHopLog log) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: log.logLevelColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: log.logLevelColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            log.logLevelIcon,
            color: log.logLevelColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.message,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDateTime(log.occurredAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: log.logLevelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.logLevel.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: log.logLevelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(MultiHopController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Settings',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                IconButton(
                  icon: Icon(
                    controller.showAdvancedSettings
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onPressed: controller.toggleAdvancedSettings,
                ),
              ],
            ),
            if (controller.showAdvancedSettings) ...[
              const SizedBox(height: 16),
              _buildSettingDropdown(
                'Protocol',
                controller.selectedProtocol,
                controller.protocols,
                controller.setProtocol,
              ),
              const SizedBox(height: 12),
              _buildSettingDropdown(
                'Encryption Level',
                controller.selectedEncryption,
                controller.encryptionLevels,
                controller.setEncryption,
              ),
              const SizedBox(height: 12),
              _buildSettingDropdown(
                'Routing Strategy',
                controller.selectedRouting,
                controller.routingStrategies,
                controller.setRouting,
              ),
              const SizedBox(height: 16),
              _buildSettingSwitch(
                'Auto Optimize',
                'Automatically optimize route for best performance',
                controller.autoOptimize,
                controller.setAutoOptimize,
              ),
              _buildSettingSwitch(
                'Failover Enabled',
                'Automatically switch to backup servers on failure',
                controller.failoverEnabled,
                controller.setFailoverEnabled,
              ),
              const SizedBox(height: 16),
              _buildSettingSlider(
                'Max Hops',
                controller.maxHops.toDouble(),
                1,
                5,
                (value) => controller.setMaxHops(value.round()),
              ),
              _buildSettingSlider(
                'Connection Timeout (seconds)',
                controller.connectionTimeout.toDouble(),
                10,
                60,
                (value) => controller.setConnectionTimeout(value.round()),
              ),
              _buildSettingSlider(
                'Retry Attempts',
                controller.retryAttempts.toDouble(),
                1,
                10,
                (value) => controller.setRetryAttempts(value.round()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option.toUpperCase(),
                style: TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSettingSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              value.round().toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Dialog Methods
  void _showCreateConnectionDialog(
      BuildContext context, MultiHopController controller) {
    final nameController = TextEditingController();
    final selectedServers = <String>[];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Multi-Hop Connection'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Connection Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select servers for your multi-hop route:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: [
                    // This would be populated with actual server data
                    _buildServerSelectionItem(
                        'US East (New York)', 'us-east-1', selectedServers),
                    _buildServerSelectionItem(
                        'UK (London)', 'uk-london-1', selectedServers),
                    _buildServerSelectionItem('Germany (Frankfurt)',
                        'de-frankfurt-1', selectedServers),
                    _buildServerSelectionItem(
                        'Japan (Tokyo)', 'jp-tokyo-1', selectedServers),
                    _buildServerSelectionItem(
                        'Australia (Sydney)', 'au-sydney-1', selectedServers),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  selectedServers.isNotEmpty) {
                controller.createConnection(
                    nameController.text, selectedServers);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildServerSelectionItem(
      String name, String id, List<String> selectedServers) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isSelected = selectedServers.contains(id);

        return CheckboxListTile(
          title: Text(name),
          subtitle: Text('Latency: ${(50 + (id.hashCode % 100)).abs()}ms'),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedServers.add(id);
              } else {
                selectedServers.remove(id);
              }
            });
          },
        );
      },
    );
  }

  void _showQuickConnectDialog(
      BuildContext context, MultiHopController controller) {
    if (controller.connections.isEmpty) {
      Get.snackbar(
        'No Connections',
        'Create a multi-hop connection first',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Connect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a connection to connect to:'),
            const SizedBox(height: 16),
            ...controller.connections.map((connection) {
              return ListTile(
                title: Text(connection.connectionName),
                subtitle: Text(connection.routePath),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  controller.connectToMultiHop(connection.id);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFullLogsDialog(
      BuildContext context, MultiHopController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Logs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.separated(
            itemCount: controller.connectionLogs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final log = controller.connectionLogs[index];
              return _buildLogItem(log);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Multi-Hop VPN Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Multi-Hop VPN?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Multi-Hop VPN routes your traffic through multiple servers in sequence, providing enhanced security and privacy by making it extremely difficult to trace your connection back to its origin.',
              ),
              const SizedBox(height: 16),
              Text(
                'Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                  '• Enhanced privacy and anonymity\n• Protection against traffic analysis\n• Redundancy and failover protection\n• Bypass advanced censorship'),
              const SizedBox(height: 16),
              Text(
                'Trade-offs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                  '• Increased latency\n• Reduced speed\n• Higher resource usage'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleConnectionAction(String action, MultiHopConnection connection,
      MultiHopController controller) {
    switch (action) {
      case 'connect':
        controller.connectToMultiHop(connection.id);
        break;
      case 'edit':
        // TODO: Implement edit connection dialog
        Get.snackbar('Coming Soon', 'Edit connection feature coming soon');
        break;
      case 'duplicate':
        // TODO: Implement duplicate connection
        Get.snackbar('Coming Soon', 'Duplicate connection feature coming soon');
        break;
      case 'delete':
        _showDeleteConfirmationDialog(Get.context!, connection, controller);
        break;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context,
      MultiHopConnection connection, MultiHopController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Connection'),
        content: Text(
            'Are you sure you want to delete "${connection.connectionName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteConnection(connection.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
