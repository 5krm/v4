import 'package:get_storage/get_storage.dart';

class DnsService {
  static final GetStorage _storage = GetStorage();
  static const String _customDnsEnabledKey = 'custom_dns_enabled';
  static const String _primaryDnsKey = 'primary_dns';
  static const String _secondaryDnsKey = 'secondary_dns';
  static const String _dnsProviderKey = 'dns_provider';
  static const String _blockAdsKey = 'dns_block_ads';
  static const String _blockMalwareKey = 'dns_block_malware';
  static const String _blockTrackingKey = 'dns_block_tracking';

  // Predefined DNS providers
  static const List<DnsProvider> dnsProviders = [
    DnsProvider(
      id: 'default',
      name: 'Default (ISP)',
      description: 'Use your ISP\'s DNS servers',
      primaryDns: '',
      secondaryDns: '',
      features: [],
      isCustom: false,
    ),
    DnsProvider(
      id: 'cloudflare',
      name: 'Cloudflare',
      description: 'Fast and privacy-focused DNS',
      primaryDns: '1.1.1.1',
      secondaryDns: '1.0.0.1',
      features: [DnsFeature.fast, DnsFeature.privacy],
      isCustom: false,
    ),
    DnsProvider(
      id: 'cloudflare_families',
      name: 'Cloudflare for Families',
      description: 'Blocks malware and adult content',
      primaryDns: '1.1.1.3',
      secondaryDns: '1.0.0.3',
      features: [DnsFeature.fast, DnsFeature.privacy, DnsFeature.familySafe],
      isCustom: false,
    ),
    DnsProvider(
      id: 'google',
      name: 'Google Public DNS',
      description: 'Google\'s fast and reliable DNS',
      primaryDns: '8.8.8.8',
      secondaryDns: '8.8.4.4',
      features: [DnsFeature.fast, DnsFeature.reliable],
      isCustom: false,
    ),
    DnsProvider(
      id: 'opendns',
      name: 'OpenDNS',
      description: 'Security and content filtering',
      primaryDns: '208.67.222.222',
      secondaryDns: '208.67.220.220',
      features: [DnsFeature.security, DnsFeature.filtering],
      isCustom: false,
    ),
    DnsProvider(
      id: 'opendns_family',
      name: 'OpenDNS FamilyShield',
      description: 'Blocks adult content automatically',
      primaryDns: '208.67.222.123',
      secondaryDns: '208.67.220.123',
      features: [
        DnsFeature.security,
        DnsFeature.filtering,
        DnsFeature.familySafe
      ],
      isCustom: false,
    ),
    DnsProvider(
      id: 'quad9',
      name: 'Quad9',
      description: 'Security-focused DNS with threat blocking',
      primaryDns: '9.9.9.9',
      secondaryDns: '149.112.112.112',
      features: [DnsFeature.security, DnsFeature.privacy],
      isCustom: false,
    ),
    DnsProvider(
      id: 'adguard',
      name: 'AdGuard DNS',
      description: 'Blocks ads and trackers',
      primaryDns: '94.140.14.14',
      secondaryDns: '94.140.15.15',
      features: [DnsFeature.adBlocking, DnsFeature.privacy],
      isCustom: false,
    ),
    DnsProvider(
      id: 'adguard_family',
      name: 'AdGuard Family Protection',
      description: 'Blocks ads and adult content',
      primaryDns: '94.140.14.15',
      secondaryDns: '94.140.15.16',
      features: [
        DnsFeature.adBlocking,
        DnsFeature.privacy,
        DnsFeature.familySafe
      ],
      isCustom: false,
    ),
    DnsProvider(
      id: 'custom',
      name: 'Custom DNS',
      description: 'Enter your own DNS servers',
      primaryDns: '',
      secondaryDns: '',
      features: [],
      isCustom: true,
    ),
  ];

  // Check if custom DNS is enabled
  static bool isCustomDnsEnabled() {
    return _storage.read(_customDnsEnabledKey) ?? false;
  }

  // Enable/disable custom DNS
  static void setCustomDnsEnabled(bool enabled) {
    _storage.write(_customDnsEnabledKey, enabled);
  }

  // Get current DNS provider
  static DnsProvider getCurrentDnsProvider() {
    final providerId = _storage.read(_dnsProviderKey) ?? 'default';
    return dnsProviders.firstWhere(
      (provider) => provider.id == providerId,
      orElse: () => dnsProviders.first,
    );
  }

  // Set DNS provider
  static void setDnsProvider(String providerId) {
    _storage.write(_dnsProviderKey, providerId);
  }

  // Get custom DNS servers
  static DnsServers getCustomDnsServers() {
    return DnsServers(
      primary: _storage.read(_primaryDnsKey) ?? '',
      secondary: _storage.read(_secondaryDnsKey) ?? '',
    );
  }

  // Set custom DNS servers
  static void setCustomDnsServers(String primary, String secondary) {
    _storage.write(_primaryDnsKey, primary);
    _storage.write(_secondaryDnsKey, secondary);
  }

  // Get DNS filtering options
  static DnsFiltering getDnsFiltering() {
    return DnsFiltering(
      blockAds: _storage.read(_blockAdsKey) ?? false,
      blockMalware: _storage.read(_blockMalwareKey) ?? true,
      blockTracking: _storage.read(_blockTrackingKey) ?? false,
    );
  }

  // Set DNS filtering options
  static void setDnsFiltering(DnsFiltering filtering) {
    _storage.write(_blockAdsKey, filtering.blockAds);
    _storage.write(_blockMalwareKey, filtering.blockMalware);
    _storage.write(_blockTrackingKey, filtering.blockTracking);
  }

  // Reset DNS settings to default
  static void resetToDefault() {
    _storage.remove(_customDnsEnabledKey);
    _storage.remove(_dnsProviderKey);
    _storage.remove(_primaryDnsKey);
    _storage.remove(_secondaryDnsKey);
    _storage.remove(_blockAdsKey);
    _storage.remove(_blockMalwareKey);
    _storage.remove(_blockTrackingKey);
  }

  // Validate DNS server address
  static bool isValidDnsServer(String dns) {
    if (dns.isEmpty) return true; // Allow empty secondary DNS

    // Basic IPv4 validation
    final ipv4Regex = RegExp(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    if (ipv4Regex.hasMatch(dns)) return true;

    // Basic IPv6 validation (simplified)
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    if (ipv6Regex.hasMatch(dns)) return true;

    return false;
  }

  // Test DNS server connectivity (mock implementation)
  static Future<DnsTestResult> testDnsServer(String dnsServer) async {
    // Simulate DNS test
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock results based on known DNS servers
    if (dnsServer == '1.1.1.1' || dnsServer == '8.8.8.8') {
      return DnsTestResult(
        server: dnsServer,
        isReachable: true,
        responseTime: 15,
        error: null,
      );
    } else if (dnsServer == '9.9.9.9' || dnsServer.startsWith('208.67')) {
      return DnsTestResult(
        server: dnsServer,
        isReachable: true,
        responseTime: 25,
        error: null,
      );
    } else if (dnsServer.isEmpty) {
      return DnsTestResult(
        server: dnsServer,
        isReachable: false,
        responseTime: -1,
        error: 'Empty DNS server',
      );
    } else {
      return DnsTestResult(
        server: dnsServer,
        isReachable: true,
        responseTime: 45,
        error: null,
      );
    }
  }

  // Get DNS configuration summary
  static DnsConfiguration getCurrentConfiguration() {
    final provider = getCurrentDnsProvider();
    final custom = getCustomDnsServers();
    final filtering = getDnsFiltering();

    return DnsConfiguration(
      isEnabled: isCustomDnsEnabled(),
      provider: provider,
      customServers: custom,
      filtering: filtering,
    );
  }
}

class DnsProvider {
  final String id;
  final String name;
  final String description;
  final String primaryDns;
  final String secondaryDns;
  final List<DnsFeature> features;
  final bool isCustom;

  const DnsProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryDns,
    required this.secondaryDns,
    required this.features,
    required this.isCustom,
  });

  bool hasFeature(DnsFeature feature) => features.contains(feature);
}

class DnsServers {
  final String primary;
  final String secondary;

  DnsServers({
    required this.primary,
    required this.secondary,
  });
}

class DnsFiltering {
  final bool blockAds;
  final bool blockMalware;
  final bool blockTracking;

  DnsFiltering({
    required this.blockAds,
    required this.blockMalware,
    required this.blockTracking,
  });
}

class DnsTestResult {
  final String server;
  final bool isReachable;
  final int responseTime;
  final String? error;

  DnsTestResult({
    required this.server,
    required this.isReachable,
    required this.responseTime,
    this.error,
  });

  String get responseTimeFormatted => isReachable ? '${responseTime}ms' : 'N/A';
}

class DnsConfiguration {
  final bool isEnabled;
  final DnsProvider provider;
  final DnsServers customServers;
  final DnsFiltering filtering;

  DnsConfiguration({
    required this.isEnabled,
    required this.provider,
    required this.customServers,
    required this.filtering,
  });
}

enum DnsFeature {
  fast,
  privacy,
  security,
  adBlocking,
  familySafe,
  filtering,
  reliable,
}
