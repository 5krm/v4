import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../utils/app_layout.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../../utils/my_helper.dart';
import '../../../utils/text_util.dart';
import '../../widgets/elegant_components.dart';
import '../../widgets/my_snake_bar.dart';
import '../analytics/analytics_screen_simple.dart';
import 'web_view_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool? fromFreePlan;

  const SettingsScreen({super.key, this.fromFreePlan = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GetStorage sharedPreferences;
  bool _autoConnect = false;
  bool _saveLastServer = true;
  bool _notifications = true;
  bool _removeAds = false;
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    sharedPreferences = GetStorage();
    isPremium = sharedPref.read(MyHelper.isAccountPremium) ?? false;
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _autoConnect = sharedPreferences.read(MyHelper.autoConnect) ?? false;
      _saveLastServer = sharedPreferences.read(MyHelper.saveLastServer) ?? true;
      _notifications = sharedPreferences.read(MyHelper.notification) ?? true;
      _removeAds = sharedPreferences.read(MyHelper.removeAds) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: MyColor.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!widget.fromFreePlan!) {
                          AppLayout.screenPortrait();
                        }
                        Get.back();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: MyColor.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: MyColor.textSecondary.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: MyColor.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings',
                      style: outfitSemiBold.copyWith(
                        fontSize: 24,
                        color: MyColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Settings Section
                        Text(
                          'App Settings',
                          style: outfitSemiBold.copyWith(
                            fontSize: 18,
                            color: MyColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ElegantCard(
                          child: Column(
                            children: [
                              _buildSettingItem(
                                icon: Icons.power_settings_new,
                                title: 'Auto Connect',
                                subtitle:
                                    'Connect automatically when app starts',
                                isSwitch: true,
                                switchValue: _autoConnect,
                                onSwitchChanged: (value) {
                                  setState(() {
                                    _autoConnect = value;
                                  });
                                  sharedPreferences.write(
                                      MyHelper.autoConnect, value);
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                icon: Icons.save,
                                title: 'Save Last Server',
                                subtitle: 'Remember last selected server',
                                isSwitch: true,
                                switchValue: _saveLastServer,
                                onSwitchChanged: (value) {
                                  setState(() {
                                    _saveLastServer = value;
                                  });
                                  sharedPreferences.write(
                                      MyHelper.saveLastServer, value);
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: 'Receive app notifications',
                                isSwitch: true,
                                switchValue: _notifications,
                                onSwitchChanged: (value) {
                                  setState(() {
                                    _notifications = value;
                                  });
                                  sharedPreferences.write(
                                      MyHelper.notification, value);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Premium Settings
                        Text(
                          'Premium Features',
                          style: outfitSemiBold.copyWith(
                            fontSize: 18,
                            color: MyColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ElegantCard(
                          child: _buildSettingItem(
                            icon: Icons.block,
                            title: 'Remove Ads',
                            subtitle: isPremium
                                ? 'Hide all advertisements'
                                : 'Upgrade to premium',
                            isSwitch: true,
                            isPremium: !isPremium,
                            switchValue: _removeAds,
                            onSwitchChanged: (value) {
                              if (isPremium) {
                                setState(() {
                                  _removeAds = value;
                                });
                                sharedPreferences.write(
                                    MyHelper.removeAds, value);
                              } else {
                                MySnakeBar.showSnakeBar(
                                  'Remove ads',
                                  'Upgrade to premium to enable this feature',
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Analytics Section
                        Text(
                          'Analytics',
                          style: outfitSemiBold.copyWith(
                            fontSize: 18,
                            color: MyColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ElegantCard(
                          child: _buildSettingItem(
                            icon: Icons.analytics_outlined,
                            title: 'Usage Analytics',
                            subtitle: 'View your VPN usage statistics',
                            onTap: () {
                              Get.to(() => const AnalyticsScreen());
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Support & Legal
                        Text(
                          'Support & Legal',
                          style: outfitSemiBold.copyWith(
                            fontSize: 18,
                            color: MyColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ElegantCard(
                          child: Column(
                            children: [
                              _buildSettingItem(
                                icon: Icons.help_outline,
                                title: 'FAQ',
                                subtitle: 'Frequently asked questions',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebViewScreen(
                                        url: sharedPreferences
                                            .read(MyHelper.faqUrl),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                icon: Icons.contact_support,
                                title: 'Contact Us',
                                subtitle: 'Get support and assistance',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebViewScreen(
                                        url: sharedPreferences
                                            .read(MyHelper.contactUrl),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                icon: Icons.description,
                                title: 'Terms & Conditions',
                                subtitle: 'Read our terms of service',
                                onTap: () {
                                  final url = sharedPreferences
                                      .read(MyHelper.termsAndCondition);
                                  if (url != null && url.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WebViewScreen(
                                          url: url,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Terms & Conditions URL not available'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                icon: Icons.privacy_tip,
                                title: 'Privacy Policy',
                                subtitle: 'How we protect your data',
                                onTap: () {
                                  final url = sharedPreferences
                                      .read(MyHelper.privacyPolicy);
                                  if (url != null && url.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WebViewScreen(
                                          url: url,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Privacy Policy URL not available'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSwitch = false,
    bool switchValue = false,
    bool isPremium = false,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: MyColor.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: MyColor.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: outfitSemiBold.copyWith(
                          fontSize: 16,
                          color: MyColor.textPrimary,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: MyColor.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PRO',
                            style: outfitMedium.copyWith(
                              fontSize: 10,
                              color: MyColor.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: outfitRegular.copyWith(
                      fontSize: 14,
                      color: MyColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSwitch)
              ModernSwitch(
                value: switchValue,
                onChanged: onSwitchChanged,
              )
            else
              Icon(
                Icons.chevron_right,
                color: MyColor.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 60),
      color: MyColor.textSecondary.withOpacity(0.1),
    );
  }
}
