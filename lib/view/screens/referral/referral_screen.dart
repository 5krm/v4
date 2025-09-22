import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../controller/referral_controller.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralController referralController = Get.find<ReferralController>();
  final TextEditingController _referralCodeController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Load referral stats when screen opens
    referralController.getReferralStats();
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Referral Program',
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
        child: Obx(() {
          if (referralController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: MyColor.accent,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await referralController.getReferralStats();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Referral Code Card
                  _buildReferralCodeCard(),

                  const SizedBox(height: 20),

                  // Stats Cards
                  _buildStatsSection(),

                  const SizedBox(height: 20),

                  // Apply Referral Code Section
                  _buildApplyReferralSection(),

                  const SizedBox(height: 20),

                  // How It Works
                  _buildHowItWorksSection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Code',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: MyColor.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColor.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralController.referralCode.value,
                    style: outfitBold.copyWith(
                      color: MyColor.textAccent,
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: referralController.referralCode.value));
                    Get.snackbar(
                      'Copied!',
                      'Referral code copied to clipboard',
                      backgroundColor: MyColor.cardBg,
                      colorText: MyColor.textPrimary,
                    );
                  },
                  icon: const Icon(
                    Icons.copy,
                    color: MyColor.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Share this code with your friends and earn rewards when they sign up!',
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Referrals',
                '${referralController.totalReferrals.value}',
                Icons.group,
                MyColor.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Total Earnings',
                '\$${referralController.totalEarnings.value.toStringAsFixed(2)}',
                Icons.attach_money,
                MyColor.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending Rewards',
                '\$${referralController.pendingRewards.value.toStringAsFixed(2)}',
                Icons.hourglass_empty,
                MyColor.warning,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'Claimed Rewards',
                '\$${referralController.claimedRewards.value.toStringAsFixed(2)}',
                Icons.check_circle,
                MyColor.accent,
              ),
            ),
          ],
        ),
      ],
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
            textAlign: TextAlign.center,
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

  Widget _buildApplyReferralSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a Referral Code?',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Enter a referral code to get rewards',
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _referralCodeController,
            style: outfitRegular.copyWith(
              color: MyColor.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter referral code',
              hintStyle: outfitRegular.copyWith(
                color: MyColor.textSecondary,
              ),
              filled: true,
              fillColor: MyColor.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: MyColor.glassBorder,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: MyColor.glassBorder,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: MyColor.accent,
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: referralController.isApplyingCode.value
                      ? null
                      : () async {
                          if (_referralCodeController.text.isNotEmpty) {
                            final success =
                                await referralController.applyReferralCode(
                                    _referralCodeController.text.trim());
                            if (success) {
                              Get.snackbar(
                                'Success',
                                'Referral code applied successfully!',
                                backgroundColor: MyColor.cardBg,
                                colorText: MyColor.textPrimary,
                              );
                              _referralCodeController.clear();
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to apply referral code',
                                backgroundColor: MyColor.cardBg,
                                colorText: MyColor.textPrimary,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: referralController.isApplyingCode.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Apply Referral Code',
                          style: outfitSemiBold.copyWith(fontSize: 16),
                        ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          _buildStepItem(1, 'Share your referral code with friends'),
          const SizedBox(height: 10),
          _buildStepItem(2, 'Your friends sign up using your code'),
          const SizedBox(height: 10),
          _buildStepItem(3, 'Both you and your friend receive rewards'),
          const SizedBox(height: 10),
          _buildStepItem(4, 'Track your earnings in this section'),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MyColor.accent,
          ),
          child: Center(
            child: Text(
              '$step',
              style: outfitBold.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
