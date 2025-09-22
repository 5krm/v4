import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../service/network_scanner_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/customBtn/modern_button.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({super.key});

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen> {
  List<NetworkDevice> _devices = [];
  ScanProgress? _scanProgress;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _listenToStreams();
  }

  void _listenToStreams() {
    NetworkScannerService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    });

    NetworkScannerService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _scanProgress = progress;
          _isScanning = !progress.isComplete;
        });
      }
    });
  }

  void _startScan() async {
    setState(() {
      _devices.clear();
      _isScanning = true;
    });

    await NetworkScannerService.startScan();
  }

  void _stopScan() {
    NetworkScannerService.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Network Scanner',
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
        child: Column(
          children: [
            // Scan Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wifi_find,
                          color: MyColor.accent,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Network Scanner',
                                style: outfitSemiBold.copyWith(
                                  color: MyColor.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover devices on your local network',
                                style: outfitRegular.copyWith(
                                  color: MyColor.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isScanning && _scanProgress != null) ...[
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _scanProgress!.phase,
                                style: outfitMedium.copyWith(
                                  color: MyColor.textAccent,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_scanProgress!.current}/${_scanProgress!.total}',
                                style: outfitRegular.copyWith(
                                  color: MyColor.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _scanProgress!.percentage,
                            backgroundColor: MyColor.cardBg,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MyColor.accent,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _scanProgress!.currentIP,
                            style: outfitRegular.copyWith(
                              color: MyColor.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ModernButton(
                        text: 'Stop Scan',
                        icon: Icons.stop,
                        onPressed: _stopScan,
                        isOutlined: true,
                      ),
                    ] else ...[
                      ModernButton(
                        text: _devices.isEmpty ? 'Start Scan' : 'Scan Again',
                        icon: Icons.search,
                        onPressed: _startScan,
                        isGradient: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Devices List
            if (_devices.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Found Devices (${_devices.length})',
                      style: outfitSemiBold.copyWith(
                        color: MyColor.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (!_isScanning)
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Refresh devices list
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: MyColor.accent,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return _buildDeviceCard(device);
                  },
                ),
              ),
            ] else if (!_isScanning) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: MyColor.textSecondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No devices found',
                        style: outfitMedium.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a scan to discover devices',
                        style: outfitRegular.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(NetworkDevice device) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showDeviceDetails(device),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDeviceColor(device.deviceType).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: _getDeviceColor(device.deviceType),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.hostname,
                  style: outfitSemiBold.copyWith(
                    color: MyColor.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.ip,
                  style: outfitRegular.copyWith(
                    color: MyColor.textAccent,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.deviceType,
                  style: outfitRegular.copyWith(
                    color: MyColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: device.isReachable ? MyColor.success : MyColor.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                device.responseTimeFormatted,
                style: outfitRegular.copyWith(
                  color: MyColor.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'router':
        return Icons.router;
      case 'computer':
        return Icons.computer;
      case 'phone':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'smart tv':
        return Icons.tv;
      case 'iot device':
        return Icons.device_hub;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getDeviceColor(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'router':
        return MyColor.primary;
      case 'computer':
        return MyColor.accent;
      case 'phone':
        return MyColor.success;
      case 'tablet':
        return MyColor.warning;
      case 'smart tv':
        return MyColor.primaryLight;
      case 'iot device':
        return MyColor.accentLight;
      default:
        return MyColor.textSecondary;
    }
  }

  void _showDeviceDetails(NetworkDevice device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: MyColor.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MyColor.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getDeviceColor(device.deviceType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getDeviceIcon(device.deviceType),
                    color: _getDeviceColor(device.deviceType),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.hostname,
                        style: outfitSemiBold.copyWith(
                          color: MyColor.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.deviceType,
                        style: outfitRegular.copyWith(
                          color: MyColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('IP Address', device.ip),
            _buildDetailRow('MAC Address', device.mac),
            _buildDetailRow('Vendor', device.vendor),
            _buildDetailRow('Response Time', device.responseTimeFormatted),
            _buildDetailRow('Last Seen', device.lastSeenFormatted),
            _buildDetailRow(
                'Status', device.isReachable ? 'Online' : 'Offline'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Copy IP',
                    icon: Icons.copy,
                    isOutlined: true,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: device.ip));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('IP address copied to clipboard'),
                          backgroundColor: MyColor.success,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(context),
                    isGradient: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: outfitRegular.copyWith(
                color: MyColor.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: outfitMedium.copyWith(
                color: MyColor.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    NetworkScannerService.dispose();
    super.dispose();
  }
}
