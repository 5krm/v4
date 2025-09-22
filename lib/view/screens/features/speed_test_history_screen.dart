import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/speed_test_controller.dart';
import '../../../model/speed_test_model.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';

class SpeedTestHistoryScreen extends StatefulWidget {
  const SpeedTestHistoryScreen({super.key});

  @override
  State<SpeedTestHistoryScreen> createState() => _SpeedTestHistoryScreenState();
}

class _SpeedTestHistoryScreenState extends State<SpeedTestHistoryScreen> {
  final SpeedTestController speedTestController = Get.find();
  SpeedTestHistoryModel? historyModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
    });

    final result = await speedTestController.getSpeedTestHistory();
    if (result != null) {
      setState(() {
        historyModel = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load speed test history',
        backgroundColor: MyColor.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Speed Test History',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : historyModel == null || historyModel!.data!.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: MyColor.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Speed Test History',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run a speed test to see your history here',
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: historyModel!.data!.length,
      itemBuilder: (context, index) {
        final test = historyModel!.data![index];
        return ModernCard(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: MyColor.cardBg,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${test.downloadSpeed.toStringAsFixed(2)} Mbps',
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${test.ping} ms',
                  style: outfitRegular.copyWith(
                    color: MyColor.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  test.serverName ?? 'Unknown Server',
                  style: outfitRegular.copyWith(
                    color: MyColor.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test.testTimestamp.toString(),
                  style: outfitRegular.copyWith(
                    color: MyColor.textLow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: MyColor.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
