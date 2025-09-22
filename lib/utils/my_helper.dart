// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MyHelper {
  //base urls - primary and fallback
  static const String _primaryBaseUrl = "https://eclipse.anfaan.com/";
  static const String _fallbackBaseUrl = "https://eclipse.anfaan.com/public/";
  
  static String _currentBaseUrl = _primaryBaseUrl;
  static bool _isUsingFallback = false;
  
  /// Get the current active base URL
  static String get baseUrl => _currentBaseUrl;
  
  /// Check if currently using fallback URL
  static bool get isUsingFallback => _isUsingFallback;
  
  /// Test if a URL is reachable
  static Future<bool> _testUrlConnection(String url) async {
    try {
      final response = await http.get(
        Uri.parse('${url}api/app-settings'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('URL test failed for $url: $e');
      }
      return false;
    }
  }
  
  /// Switch to fallback URL if primary fails
  static Future<bool> switchToFallbackIfNeeded() async {
    if (_isUsingFallback) {
      return true; // Already using fallback
    }
    
    // Test primary URL first
    bool primaryWorks = await _testUrlConnection(_primaryBaseUrl);
    if (primaryWorks) {
      return true; // Primary is working fine
    }
    
    if (kDebugMode) {
      debugPrint('Primary URL failed, testing fallback...');
    }
    
    // Test fallback URL
    bool fallbackWorks = await _testUrlConnection(_fallbackBaseUrl);
    if (fallbackWorks) {
      _currentBaseUrl = _fallbackBaseUrl;
      _isUsingFallback = true;
      if (kDebugMode) {
        debugPrint('Switched to fallback URL: $_fallbackBaseUrl');
      }
      return true;
    }
    
    if (kDebugMode) {
      debugPrint('Both URLs failed to connect');
    }
    return false;
  }
  
  /// Reset to primary URL (call this periodically to check if primary is back)
  static Future<void> resetToPrimaryIfAvailable() async {
    if (!_isUsingFallback) {
      return; // Already using primary
    }
    
    bool primaryWorks = await _testUrlConnection(_primaryBaseUrl);
    if (primaryWorks) {
      _currentBaseUrl = _primaryBaseUrl;
      _isUsingFallback = false;
      if (kDebugMode) {
        debugPrint('Switched back to primary URL: $_primaryBaseUrl');
      }
    }
  }
  
  /// Force switch to fallback URL
  static void forceUseFallback() {
    _currentBaseUrl = _fallbackBaseUrl;
    _isUsingFallback = true;
    if (kDebugMode) {
      debugPrint('Forced switch to fallback URL: $_fallbackBaseUrl');
    }
  }
  
  /// Force switch back to primary URL
  static void forceUsePrimary() {
    _currentBaseUrl = _primaryBaseUrl;
    _isUsingFallback = false;
    if (kDebugMode) {
      debugPrint('Forced switch to primary URL: $_primaryBaseUrl');
    }
  }
  static const String paymentBaseUrl = "https://sandbox.uddoktapay.com/";
  static const String vpnExtensionIdentifier = "com.eclipse.vpn.VPNExtensions";
  static const String appname = "My VPN";

  //from this below no need to change. If anything change app will not work
  static const String registerViaDeviceUrl = "api/device_register";
  static const String registerUrl = "api/user_registration";
  static const String loginUrl = "api/login";
  static const String logoutUrl = "api/logout";
  static const String sendOtpUrl = "api/send-otp";
  static const String verifyOtpUrl = "api/verify-otp";
  static const String changePasswordUrl = "api/password/reset";
  static const String userUrl = "api/user";
  static const String updateProfile = "api/user/update";
  static const String serverUrl = "api/servers";
  static const String advertisementUrl = "api/advertisement";
  static const String storeToken = "api/devices/store-token";
  static const String settingsUrl = "api/app-settings";
  static const String packageUrl = "api/pricings";

  // New API endpoints
  static const String analyticsDashboardUrl = "api/analytics/dashboard";
  static const String analyticsHistoryUrl = "api/analytics/history";
  static const String analyticsStatsUrl = "api/analytics/stats-summary";
  static const String recordSessionUrl = "api/analytics/record-session";
  static const String updateSessionUrl = "api/analytics/update-session";

  // Favorite servers endpoints
  static const String favoriteServersUrl = "api/favorite-servers";
  static const String addFavoriteServerUrl = "api/favorite-servers/add";
  static const String removeFavoriteServerUrl = "api/favorite-servers/remove";
  static const String isFavoriteServerUrl = "api/favorite-servers/is-favorite";

  // Referral endpoints
  static const String referralCodeUrl = "api/referral/code";
  static const String applyReferralCodeUrl = "api/referral/apply";
  static const String referralStatsUrl = "api/referral/stats";
  static const String referralHistoryUrl = "api/referral/history";

  // Speed Test endpoints
  static const String storeSpeedTestResultUrl = "api/speed-test/store";
  static const String speedTestHistoryUrl = "api/speed-test/history";
  static const String speedTestStatsUrl = "api/speed-test/stats";
  static const String speedTestChartUrl = "api/speed-test/chart-data";

  static const String createPaymentUrl = "api/checkout-v2";
  static const String verifyPaymentUrl = "api/verify-payment";

  static const String savePaymentInfoUrl = "api/package-details/save";

  // Google Auth URLs
  static const String googleAuthUrl = "api/auth/google";
  static const String googleLinkAccountUrl = "api/auth/google/link";

  //local storage
  static const String bToken = "bearer_token";
  static const String userName = "user_name";
  static const String userId = "user_id";
  static const String loginMode = "login_mode";
  static const String userEmail = "user_email";
  static const String expiaryDate = "expiary_date";
  static const String isAccountPremium = "is_account_premium";

  //ads
  static const String adsType = "adsType";

  static const String bannerAdsAndroid = "bannerAdsAndroid";
  static const String interAdsAndroid = "interAdsAndroid";
  static const String nativeAdsAndroid = "nativeAdsAndroid";
  static const String rewardAdsAndroid = "rewardAdsAndroid";
  static const String openAdsAndroid = "openAdsAndroid";

  static const String bannerAdsIos = "bannerAdsIos";
  static const String interAdsIos = "interAdsIos";
  static const String openAdsIOS = "interAdsIos";
  static const String nativeAdsIos = "nativeAdsIos";
  static const String rewardAdsIos = "rewardAdsIos";

  static const String unityAdsAppId = "unityAdsAppId";
  static const String unityAdsInterAndroid = "unityAdsInterAndroid";
  static const String unityAdsBannerAndroid = "unityAdsBannerAndroid";
  static const String unityAdsRewardAndroid = "unityAdsRewardAndroid";
  static const String unityAdsInterIos = "unityAdsInterIos";
  static const String unityAdsBannerIos = "unityAdsBannerIos";
  static const String unityAdsRewardIos = "unityAdsRewardIos";

  static const String ironAdsAppId = "ironAdsAppId";

  static const String fbBannerAdsAndroid = "fbBannerAdsAndroid";
  static const String fbInterAdsAndroid = "fbInterAdsAndroid";
  static const String fbNativeAdsAndroid = "fbNativeAdsAndroid";
  static const String fbRewardAdsAndroid = "fbRewardAdsAndroid";

  static const String fbBannerAdsIos = "fbBannerAdsIos";
  static const String fbInterAdsIos = "fbInterAdsIos";
  static const String fbNativeAdsIos = "fbNativeAdsIos";
  static const String fbRewardAdsIos = "fbRewardAdsIos";

  static const String adsInterVal = "adsInterVal";
  static const String saveAdsInterval = "save_adsInterVal";
  static const String token = 'user_token';

  //settings
  static const String privacyPolicy = "privacy_policy";
  static const String termsAndCondition = "terms_condition";
  static const String contactUrl = "contract_url";
  static const String faqUrl = "faq_url";

  //settings
  static const String autoConnect = "auto_connect";
  static const String saveLastServer = "save_last_server";
  static const String selectedServer = "selected_server";
  static const String notification = "notification";
  static const String removeAds = "removeAds";

  static const String DISMISS = "dismiss";
  static const String FAILED = "failed";
  static const String firstLaunch = "first_launch";
}
