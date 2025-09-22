// ignore_for_file: prefer_final_fields, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../service/dns_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/customBtn/modern_button.dart';

class DnsConfigurationScreen extends StatefulWidget {
  const DnsConfigurationScreen({super.key});

  @override
  State<DnsConfigurationScreen> createState() => _DnsConfigurationScreenState();
}

class _DnsConfigurationScreenState extends State<DnsConfigurationScreen> {
  late DnsConfiguration _config;
  late TextEditingController _primaryController;
  late TextEditingController _secondaryController;
  Map<String, DnsTestResult?> _testResults = {};
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _config = DnsService.getCurrentConfiguration();
    _primaryController =
        TextEditingController(text: _config.customServers.primary);
    _secondaryController =
        TextEditingController(text: _config.customServers.secondary);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _updateConfig() {
    setState(() {
      _config = DnsService.getCurrentConfiguration();
    });
  }

  Future<void> _testDnsServer(String server) async {
    if (server.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResults[server] = null;
    });

    final result = await DnsService.testDnsServer(server);

    setState(() {
      _testResults[server] = result;
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'DNS Configuration',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DNS Toggle
              ModernCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _config.isEnabled
                            ? MyColor.success.withOpacity(0.2)
                            : MyColor.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.dns,
                        color: _config.isEnabled
                            ? MyColor.success
                            : MyColor.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom DNS',
                            style: outfitSemiBold.copyWith(
                              color: MyColor.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _config.isEnabled
                                ? 'Using custom DNS servers'
                                : 'Using default DNS',
                            style: outfitRegular.copyWith(
                              color: _config.isEnabled
                                  ? MyColor.success
                                  : MyColor.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _config.isEnabled,
                      onChanged: (value) {
                        DnsService.setCustomDnsEnabled(value);
                        _updateConfig();
                      },
                      activeColor: MyColor.success,
                      activeTrackColor: MyColor.success.withOpacity(0.3),
                    ),
                  ],
                ),
              ),

              if (_config.isEnabled) ...[
                const SizedBox(height: 20),

                // DNS Provider Selection
                Text(
                  'DNS Provider',
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                ...DnsService.dnsProviders.map((provider) {
                  return _buildDnsProviderCard(provider);
                }).toList(),

                // Custom DNS Configuration
                if (_config.provider.isCustom) ...[
                  const SizedBox(height: 20),

                  Text(
                    'Custom DNS Servers',
                    style: outfitSemiBold.copyWith(
                      color: MyColor.textPrimary,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ModernCard(
                    child: Column(
                      children: [
                        _buildDnsInput(
                          'Primary DNS Server',
                          _primaryController,
                          'e.g., 8.8.8.8',
                        ),
                        const SizedBox(height: 16),
                        _buildDnsInput(
                          'Secondary DNS Server',
                          _secondaryController,
                          'e.g., 8.8.4.4 (Optional)',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ModernButton(
                                text: 'Test DNS',
                                icon: Icons.speed,
                                isOutlined: true,
                                isLoading: _isTesting,
                                onPressed: () async {
                                  if (_primaryController.text.isNotEmpty) {
                                    await _testDnsServer(
                                        _primaryController.text);
                                  }
                                  if (_secondaryController.text.isNotEmpty) {
                                    await _testDnsServer(
                                        _secondaryController.text);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernButton(
                                text: 'Save',
                                icon: Icons.save,
                                onPressed: () {
                                  DnsService.setCustomDnsServers(
                                    _primaryController.text,
                                    _secondaryController.text,
                                  );
                                  _updateConfig();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('DNS settings saved'),
                                      backgroundColor: MyColor.success,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Test Results
                  if (_testResults.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Results',
                            style: outfitSemiBold.copyWith(
                              color: MyColor.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ..._testResults.entries.map((entry) {
                            final result = entry.value;
                            if (result == null) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MyColor.cardBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    result.isReachable
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: result.isReachable
                                        ? MyColor.success
                                        : MyColor.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    result.server,
                                    style: outfitMedium.copyWith(
                                      color: MyColor.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    result.isReachable
                                        ? result.responseTimeFormatted
                                        : 'Failed',
                                    style: outfitRegular.copyWith(
                                      color: MyColor.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 20),

                // DNS Filtering Options
                Text(
                  'Filtering Options',
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                ModernCard(
                  child: Column(
                    children: [
                      _buildFilteringOption(
                        'Block Advertisements',
                        'Block ads and promotional content',
                        Icons.block,
                        _config.filtering.blockAds,
                        (value) {
                          final newFiltering = DnsFiltering(
                            blockAds: value,
                            blockMalware: _config.filtering.blockMalware,
                            blockTracking: _config.filtering.blockTracking,
                          );
                          DnsService.setDnsFiltering(newFiltering);
                          _updateConfig();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFilteringOption(
                        'Block Malware',
                        'Protect against malicious websites',
                        Icons.security,
                        _config.filtering.blockMalware,
                        (value) {
                          final newFiltering = DnsFiltering(
                            blockAds: _config.filtering.blockAds,
                            blockMalware: value,
                            blockTracking: _config.filtering.blockTracking,
                          );
                          DnsService.setDnsFiltering(newFiltering);
                          _updateConfig();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFilteringOption(
                        'Block Tracking',
                        'Prevent websites from tracking you',
                        Icons.visibility_off,
                        _config.filtering.blockTracking,
                        (value) {
                          final newFiltering = DnsFiltering(
                            blockAds: _config.filtering.blockAds,
                            blockMalware: _config.filtering.blockMalware,
                            blockTracking: value,
                          );
                          DnsService.setDnsFiltering(newFiltering);
                          _updateConfig();
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Information Card
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: MyColor.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About DNS',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoItem(
                        'DNS servers translate domain names to IP addresses'),
                    _buildInfoItem('Custom DNS can improve speed and security'),
                    _buildInfoItem(
                        'Some providers offer ad-blocking and malware protection'),
                    _buildInfoItem(
                        'Changes may take effect after reconnecting VPN'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDnsProviderCard(DnsProvider provider) {
    final isSelected = _config.provider.id == provider.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColor.primary.withOpacity(0.2)
                        : MyColor.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: MyColor.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    Icons.dns,
                    color: isSelected ? MyColor.primary : MyColor.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: outfitSemiBold.copyWith(
                          color: MyColor.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.description,
                        style: outfitRegular.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      if (!provider.isCustom &&
                          provider.primaryDns.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${provider.primaryDns}, ${provider.secondaryDns}',
                          style: outfitRegular.copyWith(
                            color: MyColor.textAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Radio<String>(
                  value: provider.id,
                  groupValue: _config.provider.id,
                  onChanged: (value) {
                    if (value != null) {
                      DnsService.setDnsProvider(value);
                      _updateConfig();
                    }
                  },
                  activeColor: MyColor.primary,
                ),
              ],
            ),
            if (provider.features.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: provider.features.map((feature) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFeatureColor(feature).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getFeatureColor(feature).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getFeatureText(feature),
                      style: outfitRegular.copyWith(
                        color: _getFeatureColor(feature),
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDnsInput(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: outfitMedium.copyWith(
            color: MyColor.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: outfitRegular.copyWith(
            color: MyColor.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: MyColor.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !DnsService.isValidDnsServer(value)) {
              return 'Invalid DNS server format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFilteringOption(
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value ? MyColor.primary.withOpacity(0.2) : MyColor.cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value ? MyColor.primary : MyColor.textSecondary,
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
                style: outfitMedium.copyWith(
                  color: MyColor.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: outfitRegular.copyWith(
                  color: MyColor.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: MyColor.primary,
          activeTrackColor: MyColor.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: MyColor.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: outfitRegular.copyWith(
                color: MyColor.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeatureColor(DnsFeature feature) {
    switch (feature) {
      case DnsFeature.fast:
        return MyColor.success;
      case DnsFeature.privacy:
        return MyColor.accent;
      case DnsFeature.security:
        return MyColor.primary;
      case DnsFeature.adBlocking:
        return MyColor.warning;
      case DnsFeature.familySafe:
        return MyColor.primaryLight;
      case DnsFeature.filtering:
        return MyColor.accentLight;
      case DnsFeature.reliable:
        return MyColor.success;
    }
  }

  String _getFeatureText(DnsFeature feature) {
    switch (feature) {
      case DnsFeature.fast:
        return 'Fast';
      case DnsFeature.privacy:
        return 'Privacy';
      case DnsFeature.security:
        return 'Security';
      case DnsFeature.adBlocking:
        return 'Ad Blocking';
      case DnsFeature.familySafe:
        return 'Family Safe';
      case DnsFeature.filtering:
        return 'Filtering';
      case DnsFeature.reliable:
        return 'Reliable';
    }
  }
}
