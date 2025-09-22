import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/platform_imports.dart';

import '../utils/my_helper.dart';


class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static bool isLoaded = false;
  static String adsType = '';
  GetStorage sharedPref = GetStorage();

  void loadAd() async {
    bool isPremium = sharedPref.read(MyHelper.isAccountPremium) ?? false;
    adsType = sharedPref.read(MyHelper.adsType);
    if (adsType.contains("0") && !isPremium) {
      debugPrint('AdMob: Loading app open ad...');
      AppOpenAd.load(
        adUnitId: sharedPref.read(Platform.isAndroid?MyHelper.openAdsAndroid:MyHelper.openAdsIOS),
        request: AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdMob: App open ad loaded successfully');
            _appOpenAd = ad;
            isLoaded = true;
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob: App open ad failed to load - $error');
          },
        ),
      );
    }
  }

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (_appOpenAd == null) {
      debugPrint('AdMob: App open ad not available, loading...');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('AdMob: App open ad already showing, skipping...');
      return;
    }
    debugPrint('AdMob: Showing app open ad');
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('AdMob: App open ad is showing');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob: App open ad failed to show - $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdMob: App open ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show(fullScreenContentCallback: FullScreenContentCallback());
  }
}
