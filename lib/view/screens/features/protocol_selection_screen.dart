// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../service/vpn_protocol_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';

class ProtocolSelectionScreen extends StatefulWidget {
  const ProtocolSelectionScreen({super.key});

  @override
  State<ProtocolSelectionScreen> createState() =>
      _ProtocolSelectionScreenState();
}

class _ProtocolSelectionScreenState extends State<ProtocolSelectionScreen> {
  late VpnProtocol _selectedProtocol;
  bool _autoSelectEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedProtocol = VpnProtocolService.getSelectedProtocol();
    _autoSelectEnabled = VpnProtocolService.getAutoSelectEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'VPN Protocol',
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
              // Auto Select Toggle
              ModernCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: MyColor.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_fix_high,
                        color: MyColor.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto Select',
                            style: outfitSemiBold.copyWith(
                              color: MyColor.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically choose the best protocol',
                            style: outfitRegular.copyWith(
                              color: MyColor.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoSelectEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoSelectEnabled = value;
                          VpnProtocolService.setAutoSelectEnabled(value);
                        });
                      },
                      activeColor: MyColor.accent,
                      activeTrackColor: MyColor.accent.withOpacity(0.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Protocol Selection
              Text(
                'Available Protocols',
                style: outfitSemiBold.copyWith(
                  color: MyColor.textPrimary,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              // Protocol List
              ...VpnProtocolService.availableProtocols.map((protocol) {
                return _buildProtocolCard(protocol);
              }).toList(),

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
                          color: MyColor.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Protocol Information',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoItem('Speed: How fast the connection performs'),
                    _buildInfoItem(
                        'Security: Level of encryption and protection'),
                    _buildInfoItem(
                        'Stability: Connection reliability and auto-reconnect'),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MyColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: MyColor.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: MyColor.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'OpenVPN UDP is recommended for most users as it provides the best balance of speed, security, and compatibility.',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolCard(VpnProtocol protocol) {
    final isSelected = _selectedProtocol.id == protocol.id;
    final stats = VpnProtocolService.getProtocolStats(protocol.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColor.primary.withOpacity(0.2)
                        : MyColor.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: MyColor.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    _getProtocolIcon(protocol.icon),
                    color: isSelected ? MyColor.primary : MyColor.textSecondary,
                    size: 28,
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
                            protocol.name,
                            style: outfitSemiBold.copyWith(
                              color: MyColor.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          if (protocol.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: MyColor.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: outfitSemiBold.copyWith(
                                  color: MyColor.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        protocol.description,
                        style: outfitRegular.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: protocol.id,
                  groupValue: _selectedProtocol.id,
                  onChanged: _autoSelectEnabled
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProtocol = protocol;
                              VpnProtocolService.setSelectedProtocol(
                                  protocol.id);
                            });
                          }
                        },
                  activeColor: MyColor.primary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Protocol Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatBadge(
                    'Speed',
                    protocol.speedText,
                    _getSpeedColor(protocol.speed),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBadge(
                    'Security',
                    protocol.securityText,
                    _getSecurityColor(protocol.security),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBadge(
                    'Stability',
                    protocol.stabilityText,
                    _getStabilityColor(protocol.stability),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Performance Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MyColor.cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPerformanceStat('Speed', stats.averageSpeedFormatted),
                  _buildPerformanceStat(
                      'Success', stats.connectionSuccessFormatted),
                  _buildPerformanceStat('Ping', stats.averagePingFormatted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: outfitSemiBold.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: outfitSemiBold.copyWith(
            color: MyColor.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: MyColor.primary,
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

  IconData _getProtocolIcon(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.shield;
      case 'security':
        return Icons.security;
      case 'phone_android':
        return Icons.phone_android;
      case 'flash_on':
        return Icons.flash_on;
      case 'visibility_off':
        return Icons.visibility_off;
      default:
        return Icons.vpn_lock;
    }
  }

  Color _getSpeedColor(VpnSpeed speed) {
    switch (speed) {
      case VpnSpeed.slow:
        return MyColor.error;
      case VpnSpeed.medium:
        return MyColor.warning;
      case VpnSpeed.fast:
        return MyColor.success;
      case VpnSpeed.fastest:
        return MyColor.accent;
    }
  }

  Color _getSecurityColor(VpnSecurity security) {
    switch (security) {
      case VpnSecurity.low:
        return MyColor.error;
      case VpnSecurity.medium:
        return MyColor.warning;
      case VpnSecurity.high:
        return MyColor.success;
      case VpnSecurity.highest:
        return MyColor.accent;
    }
  }

  Color _getStabilityColor(VpnStability stability) {
    switch (stability) {
      case VpnStability.poor:
        return MyColor.error;
      case VpnStability.fair:
        return MyColor.warning;
      case VpnStability.good:
        return MyColor.success;
      case VpnStability.excellent:
        return MyColor.accent;
    }
  }
}
