import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../service/connection_stats_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/customBtn/modern_button.dart';

class ConnectionStatsScreen extends StatefulWidget {
  const ConnectionStatsScreen({super.key});

  @override
  State<ConnectionStatsScreen> createState() => _ConnectionStatsScreenState();
}

class _ConnectionStatsScreenState extends State<ConnectionStatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Connection Statistics',
        onBackPressed: () => Navigator.pop(context),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          height: Get.find<AdsCallBack>().isBannerLoaded.value ? 50 : 0,
          color: MyColor.bg,
          child: AdsHelper().showBanner(),
        );
      }),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: StreamBuilder<ConnectionStats>(
          stream: ConnectionStatsService.statsStream,
          initialData: ConnectionStatsService.getCurrentStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Connection Status
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: stats.isConnected
                                    ? MyColor.success
                                    : MyColor.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              stats.isConnected ? 'Connected' : 'Disconnected',
                              style: outfitSemiBold.copyWith(
                                color: MyColor.textPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        if (stats.isConnected) ...[
                          const SizedBox(height: 15),
                          Text(
                            'Session Duration: ${stats.sessionDurationFormatted}',
                            style: outfitRegular.copyWith(
                              color: MyColor.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Session Stats
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Session',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Download',
                                stats.sessionDownloadFormatted,
                                Icons.download,
                                MyColor.success,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatItem(
                                'Upload',
                                stats.sessionUploadFormatted,
                                Icons.upload,
                                MyColor.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildStatItem(
                          'Total Session Data',
                          stats.sessionTotalFormatted,
                          Icons.data_usage,
                          MyColor.accent,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // All Time Stats
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Time Statistics',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatItem(
                          'Total Data Usage',
                          stats.totalDataFormatted,
                          Icons.storage,
                          MyColor.primary,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 15),
                        _buildStatItem(
                          'Total Connection Time',
                          stats.totalConnectionTimeFormatted,
                          Icons.access_time,
                          MyColor.accent,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 15),
                        _buildStatItem(
                          'Connection Count',
                          '${stats.connectionCount} times',
                          Icons.link,
                          MyColor.success,
                          isFullWidth: true,
                        ),
                        if (ConnectionStatsService.getLastResetDate() !=
                            null) ...[
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MyColor.cardBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: MyColor.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Last reset: ${_formatDate(ConnectionStatsService.getLastResetDate()!)}',
                                    style: outfitRegular.copyWith(
                                      color: MyColor.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Data Usage Chart (Mock)
                  ModernCard(
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Usage Trend',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildDataChart(stats),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reset Button
                  ModernButton(
                    text: 'Reset Statistics',
                    icon: Icons.refresh,
                    isOutlined: true,
                    onPressed: () => _showResetDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: outfitRegular.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: outfitSemiBold.copyWith(
                          color: MyColor.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: outfitRegular.copyWith(
                    color: MyColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildDataChart(ConnectionStats stats) {
    final downloadMB = stats.sessionDownload / 1024 / 1024;
    final uploadMB = stats.sessionUpload / 1024 / 1024;
    final totalMB = downloadMB + uploadMB;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildBarChart('Download', downloadMB, MyColor.success),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBarChart('Upload', uploadMB, MyColor.warning),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBarChart('Total', totalMB, MyColor.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Data Usage (MB)',
          style: outfitRegular.copyWith(
            color: MyColor.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String label, double value, Color color) {
    final maxValue = 100.0; // Max height for visualization
    final height = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: outfitRegular.copyWith(
            color: MyColor.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: SizedBox(
            width: 30,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 20,
                height: 80 * height + 10, // Minimum height of 10
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: outfitRegular.copyWith(
            color: MyColor.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColor.cardBg,
        title: Text(
          'Reset Statistics',
          style: outfitSemiBold.copyWith(
            color: MyColor.textPrimary,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This will permanently delete all connection statistics. Are you sure?',
          style: outfitRegular.copyWith(
            color: MyColor.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: outfitMedium.copyWith(
                color: MyColor.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ConnectionStatsService.resetStats();
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(
              'Reset',
              style: outfitMedium.copyWith(
                color: MyColor.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
