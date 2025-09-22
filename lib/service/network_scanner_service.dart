// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';

class NetworkScannerService {
  static bool _isScanning = false;
  static StreamController<List<NetworkDevice>> _devicesController =
      StreamController.broadcast();
  static StreamController<ScanProgress> _progressController =
      StreamController.broadcast();

  static Stream<List<NetworkDevice>> get devicesStream =>
      _devicesController.stream;
  static Stream<ScanProgress> get progressStream => _progressController.stream;

  // Start network scan
  static Future<void> startScan() async {
    if (_isScanning) return;

    _isScanning = true;
    final devices = <NetworkDevice>[];

    try {
      // Get local network info
      final networkInfo = await _getNetworkInfo();
      _progressController.add(ScanProgress(
        current: 0,
        total: 254,
        currentIP: 'Preparing scan...',
        phase: 'Initializing',
      ));

      // Simulate network scanning (in real implementation, this would scan the actual network)
      for (int i = 1; i <= 254; i++) {
        if (!_isScanning) break;

        final ip = '${networkInfo.baseIP}$i';
        _progressController.add(ScanProgress(
          current: i,
          total: 254,
          currentIP: ip,
          phase: 'Scanning',
        ));

        // Simulate ping delay
        await Future.delayed(const Duration(milliseconds: 20));

        // Randomly add some devices (simulation)
        if (_shouldAddDevice(i)) {
          final device = _generateMockDevice(ip, i);
          devices.add(device);
          _devicesController.add([...devices]);
        }
      }

      _progressController.add(ScanProgress(
        current: 254,
        total: 254,
        currentIP: 'Scan complete',
        phase: 'Complete',
      ));
    } catch (e) {
      print('Scan error: $e');
    } finally {
      _isScanning = false;
    }
  }

  // Stop network scan
  static void stopScan() {
    _isScanning = false;
  }

  // Get basic network information
  static Future<NetworkInfo> _getNetworkInfo() async {
    try {
      // In a real implementation, this would get actual network info
      // For simulation, return mock data
      return NetworkInfo(
        baseIP: '192.168.1.',
        gateway: '192.168.1.1',
        subnet: '255.255.255.0',
        localIP: '192.168.1.100',
      );
    } catch (e) {
      return NetworkInfo(
        baseIP: '192.168.1.',
        gateway: '192.168.1.1',
        subnet: '255.255.255.0',
        localIP: '192.168.1.100',
      );
    }
  }

  // Determine if we should add a device (simulation logic)
  static bool _shouldAddDevice(int hostNumber) {
    // Simulate common devices
    final commonDevices = [1, 100, 101, 102, 105, 110, 120, 150, 200];
    if (commonDevices.contains(hostNumber)) return true;

    // Random chance for other devices
    return Random().nextDouble() < 0.05;
  }

  // Generate mock device data
  static NetworkDevice _generateMockDevice(String ip, int hostNumber) {
    final random = Random();
    final deviceTypes = [
      'Router',
      'Computer',
      'Phone',
      'Tablet',
      'Smart TV',
      'IoT Device'
    ];
    final vendors = ['Apple', 'Samsung', 'Google', 'Microsoft', 'Unknown'];
    final names = [
      'iPhone',
      'MacBook',
      'Galaxy S21',
      'Windows PC',
      'Smart TV',
      'Router',
      'Tablet'
    ];

    String deviceType;
    String vendor;
    String name;

    if (hostNumber == 1) {
      deviceType = 'Router';
      vendor = 'Router';
      name = 'Gateway Router';
    } else {
      deviceType = deviceTypes[random.nextInt(deviceTypes.length)];
      vendor = vendors[random.nextInt(vendors.length)];
      name = names[random.nextInt(names.length)];
    }

    return NetworkDevice(
      ip: ip,
      mac: _generateMacAddress(),
      hostname: name,
      vendor: vendor,
      deviceType: deviceType,
      isReachable: true,
      responseTime: random.nextInt(100) + 1,
      lastSeen: DateTime.now(),
    );
  }

  // Generate random MAC address
  static String _generateMacAddress() {
    final random = Random();
    final bytes = List.generate(6, (_) => random.nextInt(256));
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  // Get network interface information
  static Future<List<NetworkInterface>> getNetworkInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      return interfaces
          .where((interface) => interface.addresses
              .any((addr) => addr.type == InternetAddressType.IPv4))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Dispose resources
  static void dispose() {
    _isScanning = false;
    _devicesController.close();
    _progressController.close();
    _devicesController = StreamController.broadcast();
    _progressController = StreamController.broadcast();
  }
}

class NetworkDevice {
  final String ip;
  final String mac;
  final String hostname;
  final String vendor;
  final String deviceType;
  final bool isReachable;
  final int responseTime;
  final DateTime lastSeen;

  NetworkDevice({
    required this.ip,
    required this.mac,
    required this.hostname,
    required this.vendor,
    required this.deviceType,
    required this.isReachable,
    required this.responseTime,
    required this.lastSeen,
  });

  String get responseTimeFormatted => '${responseTime}ms';
  String get lastSeenFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class NetworkInfo {
  final String baseIP;
  final String gateway;
  final String subnet;
  final String localIP;

  NetworkInfo({
    required this.baseIP,
    required this.gateway,
    required this.subnet,
    required this.localIP,
  });
}

class ScanProgress {
  final int current;
  final int total;
  final String currentIP;
  final String phase;

  ScanProgress({
    required this.current,
    required this.total,
    required this.currentIP,
    required this.phase,
  });

  double get percentage => total > 0 ? current / total : 0.0;
  bool get isComplete => current >= total;
}
