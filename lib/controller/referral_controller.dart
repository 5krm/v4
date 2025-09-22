// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../data/api/api_client.dart';
import '../model/referral_model.dart';
import '../utils/my_helper.dart';

class ReferralController extends GetxController {
  final ApiClient apiClient;

  ReferralController({required this.apiClient});

  var referralCode = ''.obs;
  var totalReferrals = 0.obs;
  var totalEarnings = 0.0.obs;
  var pendingRewards = 0.0.obs;
  var claimedRewards = 0.0.obs;
  var isLoading = false.obs;
  var isApplyingCode = false.obs;

  /// Get the user's referral code
  Future<void> getReferralCode() async {
    try {
      isLoading.value = true;
      final response = await apiClient.getData(MyHelper.referralCodeUrl);

      if (response.statusCode == 200) {
        final referralCodeModel = referralCodeModelFromJson(response.body);
        referralCode.value = referralCodeModel.data?.code ?? '';
      }
    } catch (e) {
      print('Error fetching referral code: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply a referral code
  Future<bool> applyReferralCode(String code) async {
    try {
      isApplyingCode.value = true;
      final response = await apiClient.postData(
        MyHelper.applyReferralCodeUrl,
        {'referral_code': code},
      );

      if (response.statusCode == 200) {
        // Refresh stats after applying code
        await getReferralStats();
        return true;
      }
      return false;
    } catch (e) {
      print('Error applying referral code: $e');
      return false;
    } finally {
      isApplyingCode.value = false;
    }
  }

  /// Get referral statistics
  Future<void> getReferralStats() async {
    try {
      isLoading.value = true;
      final response = await apiClient.getData(MyHelper.referralStatsUrl);

      if (response.statusCode == 200) {
        final referralStatsModel = referralStatsModelFromJson(response.body);
        referralCode.value = referralStatsModel.data?.referralCode ?? '';
        totalReferrals.value = referralStatsModel.data?.totalReferrals ?? 0;
        totalEarnings.value = referralStatsModel.data?.totalEarnings ?? 0.0;
        pendingRewards.value = referralStatsModel.data?.pendingRewards ?? 0.0;
        claimedRewards.value = referralStatsModel.data?.claimedRewards ?? 0.0;
      }
    } catch (e) {
      print('Error fetching referral stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
