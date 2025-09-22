import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../controller/split_tunnel_controller.dart';
import '../../../model/split_tunnel_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/modern_card.dart';

class SplitTunnelScreen extends StatelessWidget {
  const SplitTunnelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplitTunnelController());

    return Scaffold(
      backgroundColor: MyColor.bgColor,
      appBar: const CustomAppBar(
        title: 'Split Tunneling',
        isBackButtonExist: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: MyColor.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: MyColor.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(controller),
                const SizedBox(height: 16),
                _buildMainToggle(controller),
                const SizedBox(height: 16),
                if (controller.settings.enabled) ...[
                  _buildModeSelection(controller),
                  const SizedBox(height: 16),
                  _buildAppsSection(controller),
                  const SizedBox(height: 16),
                  _buildDomainsSection(controller),
                  const SizedBox(height: 16),
                  _buildIpRangesSection(controller),
                  const SizedBox(height: 16),
                  _buildAdvancedSettings(controller),
                ],
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          height: Get.find<AdsCallBack>().isBannerLoaded.value ? 50 : 0,
          color: MyColor.bg,
          child: AdsHelper().showBanner(),
        );
      }),
    );
  }

  Widget _buildHeaderCard(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.alt_route,
                    color: MyColor.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Split Tunneling',
                        style: MyFont.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MyColor.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.settings.enabled ? 'Active' : 'Inactive',
                        style: MyFont.poppins(
                          fontSize: 14,
                          color: controller.settings.enabled
                              ? MyColor.primary
                              : MyColor.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Choose which apps and websites use the VPN connection and which bypass it for direct internet access.',
              style: MyFont.poppins(
                fontSize: 14,
                color: MyColor.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainToggle(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable Split Tunneling',
                    style: MyFont.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MyColor.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Allow selective VPN routing',
                    style: MyFont.poppins(
                      fontSize: 12,
                      color: MyColor.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.settings.enabled,
              onChanged: (_) => controller.toggleSplitTunnel(),
              activeColor: MyColor.primary,
              inactiveThumbColor: MyColor.white.withOpacity(0.6),
              inactiveTrackColor: MyColor.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelection(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Tunnel Mode',
              style: MyFont.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MyColor.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModeOption(
                    controller,
                    'exclude',
                    'Exclude Apps',
                    'Selected apps bypass VPN',
                    Icons.remove_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeOption(
                    controller,
                    'include',
                    'Include Apps',
                    'Only selected apps use VPN',
                    Icons.add_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    SplitTunnelController controller,
    String mode,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = controller.settings.mode == mode;
    return GestureDetector(
      onTap: () => controller.updateSetting('mode', mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColor.primary.withOpacity(0.2)
              : MyColor.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MyColor.primary
                : MyColor.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? MyColor.primary : MyColor.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: MyFont.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? MyColor.primary : MyColor.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: MyFont.poppins(
                fontSize: 11,
                color: MyColor.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppsSection(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Apps (${controller.settings.apps.length})',
                    style: MyFont.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MyColor.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAppsDialog(controller),
                  child: Text(
                    'Manage',
                    style: MyFont.poppins(
                      fontSize: 14,
                      color: MyColor.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.settings.apps.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColor.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: MyColor.white.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No apps selected. Tap "Manage" to add apps.',
                        style: MyFont.poppins(
                          fontSize: 12,
                          color: MyColor.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.settings.apps.map((app) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MyColor.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MyColor.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      app,
                      style: MyFont.poppins(
                        fontSize: 12,
                        color: MyColor.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainsSection(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Domains (${controller.settings.domains.length})',
              style: MyFont.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MyColor.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.domainController,
                    style: MyFont.poppins(
                      fontSize: 14,
                      color: MyColor.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter domain (e.g., google.com)',
                      hintStyle: MyFont.poppins(
                        fontSize: 14,
                        color: MyColor.white.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: MyColor.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColor.white.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColor.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: MyColor.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.addDomain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: MyColor.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (controller.settings.domains.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...controller.settings.domains.map((domain) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: MyColor.white.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          domain,
                          style: MyFont.poppins(
                            fontSize: 14,
                            color: MyColor.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.removeDomain(domain),
                        icon: Icon(
                          Icons.close,
                          color: MyColor.white.withOpacity(0.6),
                          size: 16,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIpRangesSection(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IP Ranges (${controller.settings.ipRanges.length})',
              style: MyFont.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MyColor.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.ipRangeController,
                    style: MyFont.poppins(
                      fontSize: 14,
                      color: MyColor.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter IP range (e.g., 192.168.1.0/24)',
                      hintStyle: MyFont.poppins(
                        fontSize: 14,
                        color: MyColor.white.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: MyColor.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColor.white.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: MyColor.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: MyColor.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.addIpRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: MyColor.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (controller.settings.ipRanges.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...controller.settings.ipRanges.map((ipRange) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColor.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.router,
                        color: MyColor.white.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ipRange,
                          style: MyFont.poppins(
                            fontSize: 14,
                            color: MyColor.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.removeIpRange(ipRange),
                        icon: Icon(
                          Icons.close,
                          color: MyColor.white.withOpacity(0.6),
                          size: 16,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings(SplitTunnelController controller) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: MyFont.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: MyColor.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              controller,
              'Bypass Local Network',
              'Allow local network access without VPN',
              Icons.home_outlined,
              controller.settings.bypassLocalNetwork,
              (value) => controller.updateSetting('bypass_local_network', value),
            ),
            _buildSettingTile(
              controller,
              'Bypass DNS',
              'Use system DNS for split tunnel traffic',
              Icons.dns_outlined,
              controller.settings.bypassDns,
              (value) => controller.updateSetting('bypass_dns', value),
            ),
            _buildSettingTile(
              controller,
              'Auto-detect Apps',
              'Automatically detect new installed apps',
              Icons.auto_awesome_outlined,
              controller.settings.autoDetectApps,
              (value) => controller.updateSetting('auto_detect_apps', value),
            ),
            _buildSettingTile(
              controller,
              'Notifications',
              'Show notifications for split tunnel events',
              Icons.notifications_outlined,
              controller.settings.notificationsEnabled,
              (value) => controller.updateSetting('notifications_enabled', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    SplitTunnelController controller,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MyColor.white.withOpacity(0.8),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MyFont.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MyColor.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: MyFont.poppins(
                    fontSize: 12,
                    color: MyColor.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: MyColor.primary,
            inactiveThumbColor: MyColor.white.withOpacity(0.6),
            inactiveTrackColor: MyColor.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  void _showAppsDialog(SplitTunnelController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          decoration: BoxDecoration(
            color: MyColor.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MyColor.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: MyColor.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Manage Apps',
                        style: MyFont.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MyColor.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: MyColor.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: controller.updateSearchQuery,
                      style: MyFont.poppins(
                        fontSize: 14,
                        color: MyColor.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        hintStyle: MyFont.poppins(
                          fontSize: 14,
                          color: MyColor.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: MyColor.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: MyColor.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: MyColor.white.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: MyColor.white.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: MyColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.categories.map((category) {
                          final isSelected = controller.selectedCategory == category;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: MyFont.poppins(
                                  fontSize: 12,
                                  color: isSelected
                                      ? MyColor.white
                                      : MyColor.white.withOpacity(0.6),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  controller.updateSelectedCategory(category),
                              backgroundColor: MyColor.white.withOpacity(0.05),
                              selectedColor: MyColor.primary.withOpacity(0.3),
                              checkmarkColor: MyColor.white,
                              side: BorderSide(
                                color: isSelected
                                    ? MyColor.primary
                                    : MyColor.white.withOpacity(0.2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isAppsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: MyColor.primary),
                    );
                  }

                  if (controller.filteredApps.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apps,
                            color: MyColor.white.withOpacity(0.3),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No apps found',
                            style: MyFont.poppins(
                              fontSize: 16,
                              color: MyColor.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = controller.filteredApps[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: MyColor.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: MyColor.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.apps,
                              color: MyColor.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            app.name,
                            style: MyFont.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MyColor.white,
                            ),
                          ),
                          subtitle: Text(
                            app.category,
                            style: MyFont.poppins(
                              fontSize: 12,
                              color: MyColor.white.withOpacity(0.6),
                            ),
                          ),
                          trailing: Switch(
                            value: app.isSelected,
                            onChanged: (_) => controller.toggleApp(app),
                            activeColor: MyColor.primary,
                            inactiveThumbColor: MyColor.white.withOpacity(0.6),
                            inactiveTrackColor: MyColor.white.withOpacity(0.2),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
