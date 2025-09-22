import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../ads/open_ad_manager.dart';
import '../../ads/ads_helper.dart';
import '../../model/ads_model.dart';
import '../../model/settings_model.dart';
import '../../utils/app_layout.dart';
import '../../utils/my_helper.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'package:http/http.dart' as http;

class NewSplashScreen extends StatefulWidget {
  const NewSplashScreen({super.key});

  @override
  State<NewSplashScreen> createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends State<NewSplashScreen> {
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  GetStorage sharedPref = GetStorage();

  Future<void> getAdsData() async {
    AdsModel? adsModel;
    try {
      final response = await http
          .get(Uri.parse(MyHelper.baseUrl + MyHelper.advertisementUrl));
      if (response.statusCode == 200) {
        adsModel = adsModelFromJson(response.body);
        sharedPref.write(MyHelper.adsType, adsModel.data?.adsType ?? '');
        sharedPref.write(MyHelper.bannerAdsAndroid,
            adsModel.data?.admobAndroidBannerAdUnitId ?? '');
        sharedPref.write(MyHelper.interAdsAndroid,
            adsModel.data?.admobAndroidInterstitialAdUnitId ?? '');
        sharedPref.write(MyHelper.nativeAdsAndroid,
            adsModel.data?.admobAndroidNativeAdUnitId ?? '');
        sharedPref.write(MyHelper.rewardAdsAndroid,
            adsModel.data?.admobAndroidRewardAdUnitId ?? '');
        sharedPref.write(MyHelper.openAdsAndroid,
            adsModel.data?.admobAndroidAppOpenAdUnitId ?? '');

        sharedPref.write(MyHelper.interAdsIos,
            adsModel.data?.admobIosInterstitialAdUnitId ?? '');
        sharedPref.write(
            MyHelper.bannerAdsIos, adsModel.data?.admobIosBannerAdUnitId ?? '');
        sharedPref.write(MyHelper.nativeAdsIos,
            adsModel.data?.admobIosNativeAdUnitId ?? '');
        sharedPref.write(MyHelper.rewardAdsIos,
            adsModel.data?.admobIosRewardAdUnitId ?? '');
        sharedPref.write(
            MyHelper.openAdsIOS, adsModel.data?.admobIosAppOpenAdUnitId ?? '');

        sharedPref.write(
            MyHelper.unityAdsAppId, adsModel.data?.unityGameId ?? '');
        sharedPref.write(MyHelper.unityAdsInterAndroid,
            adsModel.data?.unityInterstitialAdPlacementId ?? '');
        sharedPref.write(MyHelper.unityAdsBannerAndroid,
            adsModel.data?.unityBannerAdPlacementId ?? '');
        sharedPref.write(MyHelper.unityAdsRewardAndroid, 'Rewarded_Android');

        sharedPref.write(MyHelper.unityAdsInterIos, 'Interstitial_Ios');
        sharedPref.write(MyHelper.unityAdsBannerIos, 'Banner_Ios');
        sharedPref.write(MyHelper.unityAdsRewardIos, 'Rewarded_iOS');

        sharedPref.write(
            MyHelper.ironAdsAppId, adsModel.data?.ironsourceAppKey ?? '');

        sharedPref.write(MyHelper.fbBannerAdsAndroid,
            adsModel.data?.facebookAndroidBannerAdUnitId ?? '');
        sharedPref.write(MyHelper.fbInterAdsAndroid,
            adsModel.data?.facebookAndroidInterstitialAdUnitId ?? '');
        sharedPref.write(MyHelper.fbNativeAdsAndroid,
            adsModel.data?.facebookAndroidNativeAdUnitId ?? '');
        sharedPref.write(MyHelper.fbRewardAdsAndroid,
            adsModel.data?.facebookAndroidRewardAdUnitId ?? '');

        sharedPref.write(MyHelper.fbBannerAdsIos,
            adsModel.data?.facebookIosBannerAdUnitId ?? '');
        sharedPref.write(MyHelper.fbInterAdsIos,
            adsModel.data?.facebookIosInterstitialAdUnitId ?? '');
        sharedPref.write(MyHelper.fbNativeAdsIos,
            adsModel.data?.facebookIosNativeAdUnitId ?? '');
        sharedPref.write(MyHelper.fbRewardAdsIos,
            adsModel.data?.facebookIosRewardAdUnitId ?? '');

        sharedPref.write(MyHelper.adsInterVal,
            int.parse(adsModel.data?.interstitialAdInterval ?? '0'));

        AdsHelper adsService = AdsHelper();
        adsService.initialization();

        appOpenAdManager.loadAd();
      }
    } catch (e) {
      // ignore: avoid_print
      print('___ $e');
    }
  }

  Future<void> getSettingsData() async {
    try {
      final response =
          await http.get(Uri.parse(MyHelper.baseUrl + MyHelper.settingsUrl));
      if (response.statusCode == 200) {
        SettingsModel settings = settingsModelFromJson(response.body);

        sharedPref.write(
            MyHelper.termsAndCondition, settings.data!.termsAndConditionsUrl);
        sharedPref.write(
            MyHelper.privacyPolicy, settings.data!.privacyPolicyUrl);
        sharedPref.write(MyHelper.contactUrl, settings.data!.contactUsUrl);
        sharedPref.write(MyHelper.faqUrl, settings.data!.faqUrl);
      }
    } catch (_) {}
  }

  // Check if onboarding has been shown before
  bool _hasOnboardingBeenShown() {
    return sharedPref.read('onboarding_shown') ?? false;
  }

  @override
  void initState() {
    super.initState();
    getAdsData();
    getSettingsData();
    
    // Navigate after delay with proper logic
    Future.delayed(const Duration(seconds: 3), () {
      if (AppOpenAdManager.isLoaded) {
        appOpenAdManager.showAdIfAvailable();
        // Check if onboarding has been shown before
        if (_hasOnboardingBeenShown()) {
          // Navigate directly to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Show onboarding screen and mark it as shown
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      } else {
        // Check if onboarding has been shown before
        if (_hasOnboardingBeenShown()) {
          // Navigate directly to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Show onboarding screen and mark it as shown
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLayout.screenPortrait1();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF1A1F2E),
                ],
              ),
            ),
          ),

          // Center logo/content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4F46E5),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 40),

                // App name
                const Text(
                  'eclipse vpn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // Slogan
                Text(
                  'Secure & Fast Connection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
