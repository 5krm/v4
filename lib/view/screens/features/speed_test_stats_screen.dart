import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/speed_test_controller.dart';
import '../../../model/speed_test_model.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';

class SpeedTestStatsScreen extends StatefulWidget {
  const SpeedTestStatsScreen({super.key});

  @override
  State<SpeedTestStatsScreen> createState() => _SpeedTestStatsScreenState();
}

class _SpeedTestStatsScreenState extends State<SpeedTestStatsScreen> {
  final SpeedTestController speedTestController = Get.find();
  SpeedTestStatsModel? statsModel;
  bool isLoading = true;
  String selectedTimeframe = 'all';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
    });

    final result = await speedTestController.getSpeedTestStats(
      timeframe: selectedTimeframe,
    );
    if (result != null) {
      setState(() {
        statsModel = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load speed test statistics',
        backgroundColor: MyColor.error,
        colorText: Colors.white,
      );
    }
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      selectedTimeframe = timeframe;
    });
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Speed Test Statistics',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: Column(
          children: [
            _buildTimeframeSelector(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : statsModel == null
                      ? _buildErrorState()
                      : _buildStatsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = {
      'day': 'Today',
      'week': 'This Week',
      'month': 'This Month',
    
    };

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: timeframes.entries.map((entry) {
          final isSelected = entry.key == selectedTimeframe;
          return ChoiceChip(
            label: Text(
              entry.value,
              style: outfitRegular.copyWith(
                color: isSelected ? MyColor.white : MyColor.textSecondary,
              ),
            ),
            selected: isSelected,
            selectedColor: MyColor.primary,
            backgroundColor: MyColor.cardBg,
            onSelected: (selected) {
              if (selected) {
                _onTimeframeChanged(entry.key);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: MyColor.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Statistics Available',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run more speed tests to see your statistics',
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    final stats = statsModel!.data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tests',
                  stats.totalTests.toString(),
                  Icons.speed,
                  MyColor.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Avg. Ping',
                  '${stats.averagePing.toStringAsFixed(0)} ms',
                  Icons.wifi_tethering,
                  MyColor.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg. Download',
                  '${stats.averageDownload.toStringAsFixed(2)} Mbps',
                  Icons.download,
                  MyColor.success,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Avg. Upload',
                  '${stats.averageUpload.toStringAsFixed(2)} Mbps',
                  Icons.upload,
                  MyColor.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Best Performance
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Performance',
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                _buildPerformanceItem(
                  'Best Download',
                  '${stats.bestDownload.toStringAsFixed(2)} Mbps',
                  Icons.download,
                  MyColor.success,
                ),
                const SizedBox(height: 10),
                _buildPerformanceItem(
                  'Best Upload',
                  '${stats.bestUpload.toStringAsFixed(2)} Mbps',
                  Icons.upload,
                  MyColor.accent,
                ),
                const SizedBox(height: 10),
                _buildPerformanceItem(
                  'Best Ping',
                  '${stats.bestPing} ms',
                  Icons.wifi_tethering,
                  MyColor.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
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
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: outfitSemiBold.copyWith(
            color: MyColor.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
