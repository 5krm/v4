import 'package:dbug_vpn/view/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/kill_switch_controller.dart';
import '../../../model/kill_switch_model.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';


class KillSwitchScreen extends StatelessWidget {
  const KillSwitchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KillSwitchController());
    
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Kill Switch',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: LoadingWidget());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(controller),
                const SizedBox(height: 20),
                _buildMainToggle(controller),
                const SizedBox(height: 20),
                _buildAdvancedSettings(controller),
                const SizedBox(height: 20),
                _buildAppManagement(controller),
                const SizedBox(height: 20),
                _buildAutoReconnectSettings(controller),
                const SizedBox(height: 20),
                _buildNotificationSettings(controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderCard(KillSwitchController controller) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.isEnabled ? MyColor.green.withOpacity(0.2) : MyColor.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.isEnabled ? Icons.security : Icons.security_outlined,
                  color: controller.isEnabled ? MyColor.green : MyColor.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kill Switch Protection',
                      style: MyFont.h3.copyWith(color: MyColor.white),
                    ),
                    Text(
                      controller.isEnabled ? 'Active' : 'Inactive',
                      style: MyFont.body2.copyWith(
                        color: controller.isEnabled ? MyColor.green : MyColor.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Automatically blocks internet access when VPN connection drops to prevent IP leaks and maintain your privacy.',
            style: MyFont.body2.copyWith(
              color: MyColor.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle(KillSwitchController controller) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Kill Switch',
                  style: MyFont.h4.copyWith(color: MyColor.white),
                ),
                Text(
                  'Block internet when VPN disconnects',
                  style: MyFont.body2.copyWith(
                    color: MyColor.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isEnabled,
            onChanged: (value) => controller.toggleKillSwitch(),
            activeColor: MyColor.green,
            inactiveThumbColor: MyColor.textDisabled,
            inactiveTrackColor: MyColor.textDisabled.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(KillSwitchController controller) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: MyFont.h4.copyWith(color: MyColor.white),
          ),
          const SizedBox(height: 15),
          _buildSwitchTile(
            title: 'Block LAN Traffic',
            subtitle: 'Block local network access',
            value: controller.settings.blockLanTraffic,
            onChanged: (value) => controller.updateSetting('blockLanTraffic', value),
            enabled: controller.isEnabled,
          ),
          const Divider(color: Colors.white24),
          _buildSwitchTile(
            title: 'Block IPv6 Traffic',
            subtitle: 'Block IPv6 connections',
            value: controller.settings.blockIpv6Traffic,
            onChanged: (value) => controller.updateSetting('blockIpv6Traffic', value),
            enabled: controller.isEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildAppManagement(KillSwitchController controller) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Management',
            style: MyFont.h4.copyWith(color: MyColor.white),
          ),
          Text(
            'Manage which apps can bypass Kill Switch',
            style: MyFont.body2.copyWith(
              color: MyColor.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 15),
          _buildAppListTile(
            title: 'Allowed Apps',
            subtitle: '${controller.settings.allowedApps.length} apps allowed',
            icon: Icons.check_circle_outline,
            color: MyColor.green,
            onTap: () => _showAppManagementDialog(controller, true),
          ),
          const SizedBox(height: 10),
          _buildAppListTile(
            title: 'Blocked Apps',
            subtitle: '${controller.settings.blockedApps.length} apps blocked',
            icon: Icons.block,
            color: MyColor.error,
            onTap: () => _showAppManagementDialog(controller, false),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoReconnectSettings(KillSwitchController controller) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto-Reconnect',
            style: MyFont.h4.copyWith(color: MyColor.white),
          ),
          const SizedBox(height: 15),
          _buildSwitchTile(
            title: 'Enable Auto-Reconnect',
            subtitle: 'Automatically reconnect when VPN drops',
            value: controller.settings.autoReconnect,
            onChanged: (value) => controller.updateSetting('autoReconnect', value),
            enabled: controller.isEnabled,
          ),
          if (controller.settings.autoReconnect) ...[
            const Divider(color: Colors.white24),
            _buildSliderTile(
              title: 'Reconnect Attempts',
              subtitle: '${controller.settings.reconnectAttempts} attempts',
              value: controller.settings.reconnectAttempts.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) => controller.updateSetting('reconnectAttempts', value.round()),
              enabled: controller.isEnabled,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(KillSwitchController controller) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: MyFont.h4.copyWith(color: MyColor.white),
          ),
          const SizedBox(height: 15),
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Show alerts when Kill Switch activates',
            value: controller.settings.notificationEnabled,
            onChanged: (value) => controller.updateSetting('notificationEnabled', value),
            enabled: controller.isEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MyFont.body1.copyWith(
                  color: enabled ? MyColor.white : MyColor.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: MyFont.body2.copyWith(
                  color: enabled ? MyColor.white.withOpacity(0.7) : MyColor.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: MyColor.green,
          inactiveThumbColor: MyColor.textDisabled,
          inactiveTrackColor: MyColor.textDisabled.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: MyFont.body1.copyWith(
                color: enabled ? MyColor.white : MyColor.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: MyFont.body2.copyWith(
                color: enabled ? MyColor.white.withOpacity(0.7) : MyColor.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
          activeColor: MyColor.green,
          inactiveColor: MyColor.textDisabled.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildAppListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MyFont.body1.copyWith(
                      color: MyColor.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: MyFont.body2.copyWith(
                      color: MyColor.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: MyColor.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAppManagementDialog(KillSwitchController controller, bool isAllowed) {
    Get.dialog(
      AlertDialog(
        backgroundColor: MyColor.cardBg,
        title: Text(
          isAllowed ? 'Allowed Apps' : 'Blocked Apps',
          style: MyFont.h4.copyWith(color: MyColor.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAllowed 
                    ? 'These apps can access internet even when Kill Switch is active'
                    : 'These apps will be blocked when Kill Switch is active',
                style: MyFont.body2.copyWith(
                  color: MyColor.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MyColor.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'App management feature coming soon',
                  style: MyFont.body2.copyWith(
                    color: MyColor.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: MyFont.button.copyWith(color: MyColor.green),
            ),
          ),
        ],
      ),
    );
  }
}
