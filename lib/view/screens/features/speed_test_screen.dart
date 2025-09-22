// ignore_for_file: unused_field, avoid_print, unnecessary_string_interpolations

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/speed_test_controller.dart';
import '../../../service/speed_test_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/customBtn/modern_button.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with TickerProviderStateMixin {
  bool _isTestRunning = false;
  SpeedTestResult? _lastResult;
  String _currentTest = '';
  double _progress = 0.0;

  late AnimationController _speedometerController;
  late AnimationController _pulseController;
  late Animation<double> _speedometerAnimation;
  late Animation<double> _pulseAnimation;

  double _currentDownloadSpeed = 0.0;
  double _currentUploadSpeed = 0.0;
  int _currentPing = 0;

  @override
  void initState() {
    super.initState();
    _speedometerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _speedometerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _speedometerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _speedometerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _storeSpeedTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required int ping,
    required String serverLocation,
  }) async {
    try {
      final speedTestController = Get.find<SpeedTestController>();

      final data = {
        'download_speed': downloadSpeed,
        'upload_speed': uploadSpeed,
        'ping': ping,
        'server_name': serverLocation,
        'device_type': 'Mobile',
        'app_version': '1.0.0',
      };

      await speedTestController.storeSpeedTestResult(data);
    } catch (e) {
      print('Error storing speed test result: $e');
    }
  }

  Future<void> _runSpeedTest() async {
    if (_isTestRunning) return;

    setState(() {
      _isTestRunning = true;
      _progress = 0.0;
      _currentDownloadSpeed = 0.0;
      _currentUploadSpeed = 0.0;
      _currentPing = 0;
    });

    try {
      // Ping test
      setState(() {
        _currentTest = 'Testing Ping...';
        _progress = 0.1;
      });

      final ping = await SpeedTestService.testPing();
      setState(() {
        _currentPing = ping;
        _progress = 0.3;
      });

      // Download test
      setState(() {
        _currentTest = 'Testing Download Speed...';
      });

      _speedometerController.forward();
      final downloadSpeed = await SpeedTestService.testDownloadSpeed();
      setState(() {
        _currentDownloadSpeed = downloadSpeed;
        _progress = 0.6;
      });

      // Upload test
      setState(() {
        _currentTest = 'Testing Upload Speed...';
      });

      final uploadSpeed = await SpeedTestService.testUploadSpeed();
      setState(() {
        _currentUploadSpeed = uploadSpeed;
        _progress = 0.9;
      });

      // Get server location
      final serverLocation = await SpeedTestService.getServerLocation();

      setState(() {
        _progress = 1.0;
        _currentTest = 'Test Complete!';
        _lastResult = SpeedTestResult(
          downloadSpeed: downloadSpeed,
          uploadSpeed: uploadSpeed,
          ping: ping,
          serverLocation: serverLocation,
          timestamp: DateTime.now(),
        );
      });

      // Store the result in the backend
      _storeSpeedTestResult(
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        ping: ping,
        serverLocation: serverLocation,
      );
    } catch (e) {
      print('Speed test error: $e');
    } finally {
      setState(() {
        _isTestRunning = false;
        _speedometerController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Speed Test',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Main Speed Display
              GlassCard(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    _buildSpeedometer(),
                    const SizedBox(height: 30),
                    if (_isTestRunning) ...[
                      Text(
                        _currentTest,
                        style: outfitMedium.copyWith(
                          color: MyColor.textAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: MyColor.cardBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          MyColor.accent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                    ] else ...[
                      ModernButton(
                        text: 'Start Speed Test',
                        icon: Icons.speed,
                        onPressed: _runSpeedTest,
                        isGradient: true,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Speed Results
              if (_lastResult != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildSpeedCard(
                        'Download',
                        _lastResult!.downloadSpeedFormatted,
                        Icons.download,
                        MyColor.success,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSpeedCard(
                        'Upload',
                        _lastResult!.uploadSpeedFormatted,
                        Icons.upload,
                        MyColor.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpeedCard(
                        'Ping',
                        _lastResult!.pingFormatted,
                        Icons.wifi_tethering,
                        MyColor.accent,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSpeedCard(
                        'Server',
                        _lastResult!.serverLocation,
                        Icons.dns,
                        MyColor.primary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Speed Test Tips
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: MyColor.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Speed Test Tips',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTipItem('Close other apps using internet'),
                    _buildTipItem('Use Wi-Fi for best results'),
                    _buildTipItem('Test multiple times for accuracy'),
                    _buildTipItem('VPN may affect speed results'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedometer() {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _speedometerAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: SpeedometerPainter(
              progress: _speedometerAnimation.value,
              speed: _isTestRunning
                  ? _currentDownloadSpeed
                  : (_lastResult?.downloadSpeed ?? 0),
              isRunning: _isTestRunning,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isTestRunning)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.speed,
                          color: MyColor.accent,
                          size: 30,
                        ),
                      ),
                    )
                  else
                    Text(
                      _lastResult != null
                          ? '${_lastResult!.downloadSpeed.toStringAsFixed(1)}'
                          : '0.0',
                      style: outfitBold.copyWith(
                        color: MyColor.textAccent,
                        fontSize: 24,
                      ),
                    ),
                  Text(
                    'Mbps',
                    style: outfitRegular.copyWith(
                      color: MyColor.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpeedCard(
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
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
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
              tip,
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
}

class SpeedometerPainter extends CustomPainter {
  final double progress;
  final double speed;
  final bool isRunning;

  SpeedometerPainter({
    required this.progress,
    required this.speed,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final bgPaint = Paint()
      ..color = MyColor.cardBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [MyColor.accent, MyColor.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Speed indicator dots
    if (!isRunning) {
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * math.pi / 180 - math.pi / 2;
        final dotRadius = i % 3 == 0 ? 3.0 : 2.0;
        final distance = radius - 15;

        final dotCenter = Offset(
          center.dx + distance * math.cos(angle),
          center.dy + distance * math.sin(angle),
        );

        final dotPaint = Paint()
          ..color = i * 30 <= (speed * 3) ? MyColor.accent : MyColor.cardBg;

        canvas.drawCircle(dotCenter, dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.speed != speed ||
        oldDelegate.isRunning != isRunning;
  }
}
