import 'dart:convert';
import 'package:get/get.dart';
import '../data/api/api_client.dart';
import '../model/speed_test_model.dart';
import '../utils/my_helper.dart';

class SpeedTestController extends GetxController {
  final ApiClient apiClient;

  SpeedTestController({required this.apiClient});

  var isLoading = false.obs;
  var isHistoryLoading = false.obs;
  var isStatsLoading = false.obs;
  var isChartLoading = false.obs;

  // Store a new speed test result
  Future<bool> storeSpeedTestResult(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await apiClient.postData(
        MyHelper.storeSpeedTestResultUrl,
        data,
      );

      if (response.statusCode == 200) {
        final result = SpeedTestModel.fromJson(json.decode(response.body));
        if (result.status == 'success') {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error storing speed test result: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get speed test history
  Future<SpeedTestHistoryModel?> getSpeedTestHistory({
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      isHistoryLoading.value = true;
      final response = await apiClient.getData(
        '${MyHelper.speedTestHistoryUrl}?per_page=$perPage&page=$page',
      );

      if (response.statusCode == 200) {
        return SpeedTestHistoryModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching speed test history: $e');
      return null;
    } finally {
      isHistoryLoading.value = false;
    }
  }

  // Get speed test statistics
  Future<SpeedTestStatsModel?> getSpeedTestStats({
    String timeframe = 'all',
  }) async {
    try {
      isStatsLoading.value = true;
      final response = await apiClient.getData(
        '${MyHelper.speedTestStatsUrl}?timeframe=$timeframe',
      );

      if (response.statusCode == 200) {
        return SpeedTestStatsModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching speed test stats: $e');
      return null;
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Get speed test chart data
  Future<SpeedTestChartDataModel?> getSpeedTestChartData({
    String timeframe = 'month',
  }) async {
    try {
      isChartLoading.value = true;
      final response = await apiClient.getData(
        '${MyHelper.speedTestChartUrl}?timeframe=$timeframe',
      );

      if (response.statusCode == 200) {
        return SpeedTestChartDataModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching speed test chart data: $e');
      return null;
    } finally {
      isChartLoading.value = false;
    }
  }
}
