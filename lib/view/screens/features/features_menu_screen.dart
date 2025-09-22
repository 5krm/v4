import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import 'speed_test_screen.dart';
import 'speed_test_history_screen.dart';
import 'speed_test_stats_screen.dart';

class FeaturesMenuScreen extends StatelessWidget {
  const FeaturesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Features',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Speed Test Features Section
            _buildSectionHeader('Speed Test'),
            _buildFeatureItem(
              title: 'Run Speed Test',
              subtitle: 'Test your connection speed',
              icon: Icons.speed,
              onTap: () => Get.to(() => const SpeedTestScreen()),
            ),
            const SizedBox(height: 15),
            _buildFeatureItem(
              title: 'Speed Test History',
              subtitle: 'View your past speed test results',
              icon: Icons.history,
              onTap: () => Get.to(() => const SpeedTestHistoryScreen()),
            ),
            const SizedBox(height: 15),
            _buildFeatureItem(
              title: 'Speed Test Statistics',
              subtitle: 'Analyze your speed test performance',
              icon: Icons.bar_chart,
              onTap: () => Get.to(() => const SpeedTestStatsScreen()),
            ),
            const SizedBox(height: 30),

            // Other Features Section
            // _buildSectionHeader('Other Features'),
            // _buildFeatureItem(
            //   title: 'Connection Statistics',
            //   subtitle: 'View detailed connection data',
            //   icon: Icons.show_chart,
            //   onTap: () {
            //     // Navigate to connection stats screen
            //   },
            // ),
            // const SizedBox(height: 15),
            // _buildFeatureItem(
            //   title: 'Network Scanner',
            //   subtitle: 'Scan for network vulnerabilities',
            //   icon: Icons.security,
            //   onTap: () {
            //     // Navigate to network scanner screen
            //   },
            // ),
            // const SizedBox(height: 15),
            // _buildFeatureItem(
            //   title: 'Kill Switch',
            //   subtitle: 'Automatically disconnect on VPN failure',
            //   icon: Icons.power_settings_new,
            //   onTap: () {
            //     // Navigate to kill switch screen
            //   },
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          height: Get.find<AdsCallBack>().isBannerLoaded.value ? 50 : 0,
          color: MyColor.bg,
          child: AdsHelper().showBanner(),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: outfitSemiBold.copyWith(
          color: MyColor.textPrimary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: MyColor.neonGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: MyColor.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: outfitSemiBold.copyWith(
            color: MyColor.textPrimary,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: outfitRegular.copyWith(
            color: MyColor.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: MyColor.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
