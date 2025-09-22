import 'package:dbug_vpn/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auto_connect_controller.dart';
import '../../widgets/custom_card.dart';
import '../../model/auto_connect_model.dart';
import '../../utils/my_color.dart';
import '../../utils/my_font.dart';
import '../widgets/custom_button.dart';

class AutoConnectScreen extends StatelessWidget {
  const AutoConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AutoConnectController());

    return Scaffold(
      backgroundColor: MyColor.bgColor,
      appBar: AppBar(
        title: Text(
          'Auto-Connect',
          style: MyFont.myFont.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MyColor.white,
          ),
        ),
        backgroundColor: MyColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyColor.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MyColor.white),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
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
                _buildMainToggle(controller),
                const SizedBox(height: 16),
                _buildCurrentNetworkCard(controller),
                const SizedBox(height: 16),
                _buildSettingsCard(controller),
                const SizedBox(height: 16),
                _buildTrustedNetworksCard(controller),
                const SizedBox(height: 16),
                _buildUntrustedNetworksCard(controller),
                const SizedBox(height: 16),
                _buildAvailableNetworksCard(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.isEnabled.value
                      ? (controller.isMonitoring.value
                          ? Icons.radar
                          : Icons.pause_circle)
                      : Icons.stop_circle,
                  color: controller.isEnabled.value
                      ? (controller.isMonitoring.value
                          ? Colors.green
                          : Colors.orange)
                      : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${controller.statusText}',
                        style: MyFont.myFont.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MyColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.lastAction.value,
                        style: MyFont.myFont.copyWith(
                          fontSize: 14,
                          color: MyColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Trusted Networks',
                    controller.settings.value.trustedNetworksCount.toString(),
                    Icons.shield_outlined,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Untrusted Networks',
                    controller.settings.value.untrustedNetworksCount.toString(),
                    Icons.warning_outlined,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: MyFont.myFont.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: MyFont.myFont.copyWith(
              fontSize: 12,
              color: MyColor.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new,
              color: controller.isEnabled.value ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Connect',
                    style: MyFont.myFont.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automatically manage VPN connections based on network trust',
                    style: MyFont.myFont.copyWith(
                      fontSize: 14,
                      color: MyColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.isEnabled.value,
              onChanged: (value) => controller.toggleAutoConnect(value),
              activeColor: MyColor.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentNetworkCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: MyColor.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Current Network',
                  style: MyFont.myFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.hasCurrentNetwork) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentNetworkSsid.value,
                          style: MyFont.myFont.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.networkClassificationText,
                          style: MyFont.myFont.copyWith(
                            fontSize: 14,
                            color: _getClassificationColor(controller
                                .settings.value
                                .getNetworkClassification(
                              controller.currentNetworkSsid.value,
                              controller.currentNetworkBssid.value,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: MyColor.textSecondary),
                    onSelected: (value) =>
                        _handleNetworkAction(controller, value),
                    itemBuilder: (context) => [
                      if (controller.canAddCurrentNetworkAsTrusted)
                        const PopupMenuItem(
                          value: 'add_trusted',
                          child: Row(
                            children: [
                              Icon(Icons.shield, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text('Mark as Trusted'),
                            ],
                          ),
                        ),
                      if (controller.canAddCurrentNetworkAsUntrusted)
                        const PopupMenuItem(
                          value: 'add_untrusted',
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Mark as Untrusted'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'check_network',
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: MyColor.primary, size: 20),
                            SizedBox(width: 8),
                            Text('Check Network'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No network connected',
                style: MyFont.myFont.copyWith(
                  fontSize: 14,
                  color: MyColor.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: MyColor.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: MyFont.myFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Auto-connect on untrusted networks',
              'Automatically connect to VPN when joining untrusted networks',
              controller.settings.value.autoConnectUntrusted,
              (value) =>
                  _updateSetting(controller, 'autoConnectUntrusted', value),
            ),
            const Divider(),
            _buildSettingItem(
              'Auto-disconnect on trusted networks',
              'Automatically disconnect from VPN when joining trusted networks',
              controller.settings.value.autoDisconnectTrusted,
              (value) =>
                  _updateSetting(controller, 'autoDisconnectTrusted', value),
            ),
            const Divider(),
            _buildSettingItem(
              'Notifications',
              'Show notifications for auto-connect actions',
              controller.settings.value.notificationsEnabled,
              (value) =>
                  _updateSetting(controller, 'notificationsEnabled', value),
            ),
            const Divider(),
            _buildPreferredServerSelector(controller),
            const Divider(),
            _buildConnectionDelaySlider(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MyFont.myFont.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MyColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: MyFont.myFont.copyWith(
                    fontSize: 12,
                    color: MyColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: MyColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredServerSelector(AutoConnectController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Server',
          style: MyFont.myFont.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the default server for auto-connect',
          style: MyFont.myFont.copyWith(
            fontSize: 12,
            color: MyColor.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MyColor.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MyColor.black),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.getPreferredServerDisplay(),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: MyColor.textSecondary),
                style: MyFont.myFont.copyWith(
                  fontSize: 14,
                  color: MyColor.textPrimary,
                ),
                items: controller.getServerOptions().map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.updatePreferredServer(value);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConnectionDelaySlider(AutoConnectController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Delay: ${controller.settings.value.formattedConnectionDelay}',
            style: MyFont.myFont.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MyColor.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: controller.settings.value.connectionDelay.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: MyColor.primary,
            onChanged: (value) =>
                _updateSetting(controller, 'connectionDelay', value.round()),
          ),
          Text(
            'Delay before auto-connecting or disconnecting',
            style: MyFont.myFont.copyWith(
              fontSize: 12,
              color: MyColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedNetworksCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Trusted Networks',
                  style: MyFont.myFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.settings.value.trustedNetworksCount}',
                  style: MyFont.myFont.copyWith(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.settings.value.trustedNetworks.isEmpty) ...[
              Text(
                'No trusted networks added yet',
                style: MyFont.myFont.copyWith(
                  fontSize: 14,
                  color: MyColor.textSecondary,
                ),
              ),
            ] else ...[
              ...controller.settings.value.trustedNetworks.map(
                (network) => _buildNetworkItem(
                  network.ssid,
                  network.displayName,
                  network.addedTimeAgo,
                  Colors.green,
                  Icons.shield,
                  () => _showNetworkDetails(network),
                  () => controller.removeTrustedNetwork(
                      network.ssid, network.bssid),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUntrustedNetworksCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Untrusted Networks',
                  style: MyFont.myFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.settings.value.untrustedNetworksCount}',
                  style: MyFont.myFont.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.settings.value.untrustedNetworks.isEmpty) ...[
              Text(
                'No untrusted networks added yet',
                style: MyFont.myFont.copyWith(
                  fontSize: 14,
                  color: MyColor.textSecondary,
                ),
              ),
            ] else ...[
              ...controller.settings.value.untrustedNetworks.map(
                (network) => _buildNetworkItem(
                  network.ssid,
                  network.displayReason,
                  network.addedTimeAgo,
                  Colors.red,
                  Icons.warning,
                  () => _showNetworkDetails(network),
                  () => controller.removeUntrustedNetwork(
                      network.ssid, network.bssid),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableNetworksCard(AutoConnectController controller) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi_find, color: MyColor.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Available Networks',
                  style: MyFont.myFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: MyColor.primary),
                  onPressed: () => controller.loadAvailableNetworks(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.availableNetworks.isEmpty) ...[
              Text(
                'No networks found',
                style: MyFont.myFont.copyWith(
                  fontSize: 14,
                  color: MyColor.textSecondary,
                ),
              ),
            ] else ...[
              ...controller.availableNetworks.take(5).map(
                    (network) =>
                        _buildAvailableNetworkItem(controller, network),
                  ),
              if (controller.availableNetworks.length > 5) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => _showAllNetworks(controller),
                    child: Text(
                      'View all ${controller.availableNetworks.length} networks',
                      style: MyFont.myFont.copyWith(
                        color: MyColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkItem(
    String ssid,
    String subtitle,
    String timeAgo,
    Color color,
    IconData icon,
    VoidCallback onTap,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          ssid,
          style: MyFont.myFont.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: MyFont.myFont.copyWith(
                fontSize: 12,
                color: MyColor.textSecondary,
              ),
            ),
            Text(
              'Added $timeAgo',
              style: MyFont.myFont.copyWith(
                fontSize: 11,
                color: MyColor.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: onRemove,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAvailableNetworkItem(
      AutoConnectController controller, AvailableNetwork network) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          network.isSecure ? Icons.wifi_lock : Icons.wifi,
          color: _getClassificationColor(network.classification),
          size: 20,
        ),
        title: Text(
          network.ssid,
          style: MyFont.myFont.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.textPrimary,
          ),
        ),
        subtitle: Text(
          '${network.securityDisplay} • ${network.formattedSignalStrength}',
          style: MyFont.myFont.copyWith(
            fontSize: 12,
            color: MyColor.textSecondary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert,
              color: MyColor.textSecondary, size: 20),
          onSelected: (value) =>
              _handleAvailableNetworkAction(controller, network, value),
          itemBuilder: (context) => [
            if (!network.isTrusted)
              const PopupMenuItem(
                value: 'add_trusted',
                child: Row(
                  children: [
                    Icon(Icons.shield, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as Trusted'),
                  ],
                ),
              ),
            if (!network.isUntrusted)
              const PopupMenuItem(
                value: 'add_untrusted',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as Untrusted'),
                  ],
                ),
              ),
          ],
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Color _getClassificationColor(String classification) {
    switch (classification) {
      case 'trusted':
        return Colors.green;
      case 'untrusted':
        return Colors.red;
      default:
        return MyColor.textSecondary;
    }
  }

  void _handleNetworkAction(AutoConnectController controller, String action) {
    switch (action) {
      case 'add_trusted':
        _addCurrentNetworkAsTrusted(controller);
        break;
      case 'add_untrusted':
        _addCurrentNetworkAsUntrusted(controller);
        break;
      case 'check_network':
        controller.checkCurrentNetwork();
        break;
    }
  }

  void _handleAvailableNetworkAction(AutoConnectController controller,
      AvailableNetwork network, String action) {
    switch (action) {
      case 'add_trusted':
        controller.addTrustedNetwork(
          ssid: network.ssid,
          bssid: network.bssid,
          securityType: network.securityType,
          signalStrength: network.signalStrength,
          frequency: network.frequency,
        );
        break;
      case 'add_untrusted':
        controller.addUntrustedNetwork(
          ssid: network.ssid,
          bssid: network.bssid,
          securityType: network.securityType,
          signalStrength: network.signalStrength,
          frequency: network.frequency,
        );
        break;
    }
  }

  void _addCurrentNetworkAsTrusted(AutoConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Trusted Network'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Add "${controller.currentNetworkSsid.value}" to trusted networks?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g., Home WiFi, Office Network',
              ),
              onChanged: (value) => controller.settings.value =
                  controller.settings.value.copyWith(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addTrustedNetwork(
                ssid: controller.currentNetworkSsid.value,
                bssid: controller.currentNetworkBssid.value,
              );
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCurrentNetworkAsUntrusted(AutoConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Untrusted Network'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Add "${controller.currentNetworkSsid.value}" to untrusted networks?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g., Public WiFi, Unsecured network',
              ),
              onChanged: (value) => controller.settings.value =
                  controller.settings.value.copyWith(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addUntrustedNetwork(
                ssid: controller.currentNetworkSsid.value,
                bssid: controller.currentNetworkBssid.value,
              );
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updateSetting(
      AutoConnectController controller, String setting, dynamic value) {
    AutoConnectSettings updatedSettings;

    switch (setting) {
      case 'autoConnectUntrusted':
        updatedSettings =
            controller.settings.value.copyWith(autoConnectUntrusted: value);
        break;
      case 'autoDisconnectTrusted':
        updatedSettings =
            controller.settings.value.copyWith(autoDisconnectTrusted: value);
        break;
      case 'notificationsEnabled':
        updatedSettings =
            controller.settings.value.copyWith(notificationsEnabled: value);
        break;
      case 'connectionDelay':
        updatedSettings =
            controller.settings.value.copyWith(connectionDelay: value);
        break;
      default:
        return;
    }

    controller.updateSettings(updatedSettings);
  }

  void _showNetworkDetails(dynamic network) {
    Get.dialog(
      AlertDialog(
        title: Text(network.ssid),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (network is TrustedNetwork) ...[
              _buildDetailRow('BSSID', network.bssid),
              _buildDetailRow('Security', network.securityType ?? 'Unknown'),
              _buildDetailRow('Signal', network.formattedSignalStrength),
              _buildDetailRow('Frequency', network.formattedFrequency),
              _buildDetailRow('Added', network.addedTimeAgo),
              _buildDetailRow('Last Connected', network.lastConnectedTimeAgo),
              if (network.description?.isNotEmpty == true)
                _buildDetailRow('Description', network.description!),
            ] else if (network is UntrustedNetwork) ...[
              _buildDetailRow('BSSID', network.bssid),
              _buildDetailRow('Security', network.securityType ?? 'Unknown'),
              _buildDetailRow('Signal', network.formattedSignalStrength),
              _buildDetailRow('Frequency', network.formattedFrequency),
              _buildDetailRow('Added', network.addedTimeAgo),
              _buildDetailRow('Last Detected', network.lastDetectedTimeAgo),
              if (network.reason?.isNotEmpty == true)
                _buildDetailRow('Reason', network.reason!),
            ],
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: MyFont.myFont.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: MyColor.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyFont.myFont.copyWith(
                fontSize: 14,
                color: MyColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllNetworks(AutoConnectController controller) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'All Available Networks',
                style: MyFont.myFont.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MyColor.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.availableNetworks.length,
                  itemBuilder: (context, index) {
                    final network = controller.availableNetworks[index];
                    return _buildAvailableNetworkItem(controller, network);
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
