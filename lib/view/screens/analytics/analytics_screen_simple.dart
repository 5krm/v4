import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/analytics_controller.dart';
import '../../../data/api/api_client.dart';
import '../../../utils/my_font.dart';
import '../../../utils/app_layout.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsController analyticsController = Get.put(
      AnalyticsController(apiClient: Get.find<ApiClient>()),
    );

    AppLayout.screenPortrait();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, analyticsController),

            // Content
            Expanded(
              child: Obx(() {
                if (analyticsController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => analyticsController.refreshData(),
                  backgroundColor: const Color(0xFF1E293B),
                  color: const Color(0xFF4285F4),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time frame selector
                        _buildTimeFrameSelector(analyticsController),

                        const SizedBox(height: 24),

                        // Statistics cards
                        _buildStatisticsCards(analyticsController),

                        const SizedBox(height: 32),

                        // Usage chart placeholder
                        _buildUsageChartPlaceholder(),

                        const SizedBox(height: 32),

                        // Server usage
                        _buildServerUsage(analyticsController),

                        const SizedBox(height: 32),

                        // Speed Test Statistics
                        _buildSpeedTestStats(analyticsController),

                        const SizedBox(height: 32),

                        // Quick stats summary
                        _buildQuickStats(analyticsController),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'Analytics',
              style: outfitBold.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Refresh button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.refreshData(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(AnalyticsController controller) {
    final timeframes = [
      {'key': 'day', 'label': 'Today'},
      {'key': 'week', 'label': 'This Week'},
      {'key': 'month', 'label': 'This Month'},
      {'key': 'year', 'label': 'This Year'},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          return Obx(() {
            final isSelected =
                controller.selectedTimeframe.value == timeframe['key'];

            return Container(
              margin: EdgeInsets.only(
                  right: index < timeframes.length - 1 ? 12 : 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.loadDashboardData(
                    timeframe: timeframe['key']!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4285F4)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4285F4)
                            : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      timeframe['label']!,
                      style: outfitMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildStatisticsCards(AnalyticsController controller) {
    return Obx(() {
      final stats = controller.dashboardData.value?.statistics;
      if (stats == null) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Sessions',
                    '0',
                    Icons.play_circle_outline,
                    const Color(0xFF4285F4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Connection Time',
                    '00:00:00',
                    Icons.access_time,
                    const Color(0xFF34A853),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Data Usage',
                    '0 B',
                    Icons.data_usage,
                    const Color(0xFFEA4335),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '100%',
                    Icons.check_circle_outline,
                    const Color(0xFFFBBC05),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Sessions',
                  '${stats.totalSessions ?? 0}',
                  Icons.play_circle_outline,
                  const Color(0xFF4285F4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Connection Time',
                  stats.formattedTotalDuration,
                  Icons.access_time,
                  const Color(0xFF34A853),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Data Usage',
                  stats.formattedDataUsage,
                  Icons.data_usage,
                  const Color(0xFFEA4335),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Success Rate',
                  '${stats.connectionSuccessRate?.toStringAsFixed(1) ?? "100"}%',
                  Icons.check_circle_outline,
                  const Color(0xFFFBBC05),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: outfitBold.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTestStats(AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speed Test Performance',
            style: outfitSemiBold.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          // Speed test stats will be displayed here
          const Center(
            child: Text(
              'Run speed tests to see performance statistics',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to speed test screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Run Speed Test'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Usage Chart',
            style: outfitSemiBold.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          // Simplified chart placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Interactive charts will be displayed here',
                    style: outfitMedium.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Install fl_chart package for full functionality',
                    style: outfitMedium.copyWith(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerUsage(AnalyticsController controller) {
    return Obx(() {
      final serverUsage = controller.dashboardData.value?.serverUsage;
      if (serverUsage == null || serverUsage.isEmpty) {
        return _buildEmptySection(
            'Server Usage', 'No server usage data available yet');
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Usage',
              style: outfitSemiBold.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...serverUsage
                .take(5)
                .map((server) => _buildServerItem(
                      server.serverCountry ?? 'Unknown',
                      server.sessions ?? 0,
                      controller.getChartColor(serverUsage.indexOf(server)),
                    ))
                ,
          ],
        ),
      );
    });
  }

  Widget _buildServerItem(String country, int sessions, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              country,
              style: outfitMedium.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '$sessions sessions',
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AnalyticsController controller) {
    return Obx(() {
      final summary = controller.statsSummary.value;
      if (summary == null) {
        return _buildEmptySection(
            'Quick Stats', 'Stats will be available after using the VPN');
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: outfitSemiBold.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickStatRow('Today', summary.today),
            _buildQuickStatRow('This Week', summary.thisWeek),
            _buildQuickStatRow('This Month', summary.thisMonth),
            _buildQuickStatRow('All Time', summary.allTime),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStatRow(String period, dynamic stats) {
    if (stats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: outfitMedium.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            '${stats.sessions} sessions • ${stats.formattedDuration}',
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: outfitSemiBold.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
