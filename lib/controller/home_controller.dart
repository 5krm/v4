import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dbug_vpn/utils/platform_imports.dart' hide FirebaseMessaging;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';

import '../utils/debouncer.dart';
import '../utils/background_task_optimizer.dart';

import '../ads/ads_helper.dart';
import '../ads/ads_callback.dart';
import '../data/api/api_client.dart'; 
import '../model/payment_method_item.dart';
import '../model/product_package_model.dart';
import '../model/register_model.dart';
import '../model/response_model.dart';
import '../model/server_model.dart';
import '../model/user.dart';
import '../model/user_model.dart';
import '../model/vpn_config.dart';
import '../service/apis.dart';
import '../service/vpn_engine.dart';
import 'package:http/http.dart' as http;
import '../utils/my_color.dart';
import '../utils/my_helper.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  GetStorage userData = GetStorage();
  ApiClient apiClient;
  
  // Debouncer for API calls
  final Debouncer _apiDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  final Debouncer _connectionDebouncer = Debouncer(delay: Duration(milliseconds: 1000));
  final BackgroundTaskOptimizer _backgroundOptimizer = BackgroundTaskOptimizer.instance;

  HomeController({required this.apiClient});

  final vpnState = VpnEngine.vpnDisconnected.obs;

  var serversList = <Server>[].obs;
  var productList = <ProductPackage>[].obs;

  var selectedServer = Rx<Server?>(null);

  var user = Rx<User?>(null);
  var paymentInfo = Rxn<UserPackageDetails>();

  DateTime? vpnConnectedStartTime;

  void onTryConnect() {
    _connectionDebouncer.call(() {
      connectToVpn();
    });
    ever(vpnState, (state) {
      if (state == VpnEngine.vpnConnected) {
        connectedTime();
      }
    });
  }

  void connectedTime() {
    vpnConnectedStartTime = DateTime.now();
    userData.write(
        'vpnConnectedStartTime', vpnConnectedStartTime!.millisecondsSinceEpoch);
  }

  @override
  void onInit() {
    initState();
    updateVpnState().then((value) => restoreSub());
    loadCount();
    super.onInit();
    _saveFCMTOKEN();
    _startBackgroundMonitoring();
  }

  Future<void> updateVpnState() async {
    bool isVpnConnected = await VpnEngine.isVpnConnected();
    String? serverJson = userData.read(MyHelper.selectedServer);
    bool autoConnect = userData.read(MyHelper.autoConnect) ?? false;
    bool saveLastServer = userData.read(MyHelper.saveLastServer) ?? true;
    final int? startTimeMillis = userData.read('vpnConnectedStartTime');
    if (startTimeMillis != null && isVpnConnected) {
      vpnConnectedStartTime =
          DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
    }

    if (serverJson != null && (isVpnConnected || saveLastServer)) {
      selectedServer.value = Server.fromJson(jsonDecode(serverJson));
    }

    if (!isVpnConnected && autoConnect && saveLastServer) {
      onTryConnect();
    }
    vpnState.value =
        isVpnConnected ? VpnEngine.vpnConnected : VpnEngine.vpnDisconnected;
  }

  Timer? _subscriptionTimer;
  DateTime? _lastSubscriptionCheck;

  @override
  void onClose() {
    _subscriptionTimer?.cancel();
    _subscriptionTimer = null;
    _stopBackgroundMonitoring();
    super.onClose();
  }

  void startSubscriptionTimer() {
    _subscriptionTimer?.cancel();
    
    // Only start timer if user has subscription
    if (paymentInfo.value == null) return;
    
    // Check subscription status every 30 seconds instead of every second
    _subscriptionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSubscriptionStatus();
    });
    
    // Initial check
    _checkSubscriptionStatus();
  }
  
  void _checkSubscriptionStatus() {
    if (paymentInfo.value == null) {
      _subscriptionTimer?.cancel();
      _subscriptionTimer = null;
      return;
    }
    
    // Cache the current time to avoid repeated calculations
    final now = DateTime.now();
    if (_lastSubscriptionCheck != null && 
        now.difference(_lastSubscriptionCheck!).inSeconds < 25) {
      return; // Skip if checked recently
    }
    
    _lastSubscriptionCheck = now;
    
    try {
      if (isSubscribed.value && paymentInfo.value != null) {
        final currentDate = DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss.SSS')
            .format(now.toUtc().add(const Duration(hours: 6))));
        if (currentDate.isAfter(paymentInfo.value!.expiresAt!)) {
          _subscriptionTimer?.cancel();
          _subscriptionTimer = null;
          getUsers();
          if (vpnState.value == VpnEngine.vpnConnected) {
            onTryConnect();
          }
          debugPrint('HomeController: Subscription expired, timer stopped');
        }
      }
    } catch (e) {
      debugPrint('HomeController: Error checking subscription status: $e');
    }
  }
  
  /// Stop subscription timer when not needed
  void stopSubscriptionTimer() {
    _subscriptionTimer?.cancel();
    _subscriptionTimer = null;
    _lastSubscriptionCheck = null;
  }

  void _startBackgroundMonitoring() {
    _backgroundOptimizer.startVpnMonitoring(
      onVpnStateChanged: (isConnected) {
        vpnState.value = isConnected ? VpnEngine.vpnConnected : VpnEngine.vpnDisconnected;
        if (isConnected) {
          connectedTime();
        }
      },
      onSubscriptionExpired: () {
        getUsers();
        if (vpnState.value == VpnEngine.vpnConnected) {
          onTryConnect();
        }
      },
    );
  }

  void _stopBackgroundMonitoring() {
    _backgroundOptimizer.stopVpnMonitoring();
  }

  void initState() async {
    getUsers().then((value) {
      if (userData.read(MyHelper.bToken) == null ||
          userData.read(MyHelper.bToken).toString().isEmpty) {
        doRegisterAsGuest().then((value) {
          getSubscriptionPackageList();
          getServers();
        });
      } else {
        getSubscriptionPackageList();
        getServers();
      }
    });
    isSubscribed.value = userData.read(MyHelper.isAccountPremium) ?? false;
  }

  void saveSelectedServer(Server server) {
    userData.write(MyHelper.selectedServer, jsonEncode(server.toJson()));
    selectedServer.value = server;
    onTryConnect();
  }

  AdsHelper adsService = AdsHelper();
  int countAds = 1;
  int saveInterval = 0;

  Future<void> savedAds() async {
    countAds == 0 ? countAds = saveInterval : countAds = countAds - 1;
    userData.write(MyHelper.adsInterVal, countAds);
    update();
  }

  Future<void> loadCount() async {
    try {
      countAds = userData.read(MyHelper.adsInterVal);
      saveInterval = userData.read(MyHelper.saveAdsInterval);
      update();
    } catch (_) {}
  }

  void connectToVpn() async {
    if (selectedServer.value == null) {
      Get.snackbar('Info', 'Select a Location by clicking \'Change Location\'',
          colorText: Colors.white, backgroundColor: MyColor.transparent);
      return;
    } else if (selectedServer.value != null &&
        selectedServer.value!.accessType == "premium" &&
        !isSubscribed.value &&
        vpnState.value == VpnEngine.vpnDisconnected) {
      Get.snackbar('Info', 'Vpn is Premium!',
          colorText: Colors.white, backgroundColor: MyColor.transparent);
      return;
    } else if (selectedServer.value!.udpConfiguration == null &&
        selectedServer.value!.tcpConfiguration == null) {
      Get.snackbar('Info', 'Select a Location by clicking \'Change Location\'',
          colorText: Colors.white, backgroundColor: MyColor.transparent);
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      // final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      // final config = Utf8Decoder().convert(data);
      String config = '';
      if (selectedServer.value!.udpConfiguration != null) {
        config = selectedServer.value!.udpConfiguration!;
      } else if (selectedServer.value!.tcpConfiguration != null) {
        config = selectedServer.value!.tcpConfiguration!;
      }

      final vpnConfig = VpnConfig(
        country: selectedServer.value!.vpnCountry ?? "",
        username: selectedServer.value!.vpnCredentialsUsername ?? "",
        password: selectedServer.value!.vpnCredentialsPassword ?? "",
        config: config,
      );
      // Show interstitial ad for free users before connecting
      if (!isSubscribed.value) {
        AdsHelper().showInterAd(() async {
          await VpnEngine.startVpn(vpnConfig);
        });
      } else {
        await VpnEngine.startVpn(vpnConfig);
      }
    } else {
      await VpnEngine.stopVpn();
    }
  }

  bool get checkConnecting {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return false;

      case VpnEngine.vpnConnected:
        return false;

      default:
        return true;
    }
  }

  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Connect';

      case VpnEngine.vpnConnected:
        return 'Disconnect';

      default:
        return 'Connecting';
    }
  }

  Future<String> get getIPText async {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return await APIs.getPublicIpAddress();

      case VpnEngine.vpnConnected:
        return await APIs.getPublicIpAddress();

      default:
        return await APIs.getPublicIpAddress();
    }
  }

  Future<void> doRegisterAsGuest() async {
    String deviceId = await getDeviceId();
    try {
      final response = await apiClient
          .postData(MyHelper.registerViaDeviceUrl, {'device_id': deviceId});
      if (response.statusCode == 200) {
        final registerModel = registerModelFromJson(response.body);

        String? bToken = registerModel.data?.accessToken;
        user.value = registerModel.data!.user!;
        userData.write(MyHelper.bToken, bToken);
        apiClient.updateHeader(isToken: true);
        if (isSubscribed.value) {
          updateSub(false);
        }
      }
    } catch (_) {}
  }

  Future<void> getSubscriptionPackageList() async {
    _apiDebouncer.call(() async {
      try {
        final response = await apiClient.getData(MyHelper.packageUrl);
        if (response.statusCode == 200) {
          ProductPackageModel productPackageModel =
              productPackageModelFromJson(response.body);
          productList.value = productPackageModel.data ?? [];
          productIds.clear();
          productIds.addAll(productList.map((productPackageModel) => ProductId(
              id: productPackageModel.productId!, isConsumable: false)));
          getProducts();
        }
      } catch (e) {
        debugPrint("Error pa: $e");
      }
    });
  }

  Future<void> _saveFCMTOKEN() async {
    bool hasFCMToken = sharedPref.read("FCM_TOKEN") ?? false;
    if (hasFCMToken) {
      return;
    }
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String deviceId = await getDeviceId();
    final response = await apiClient.postData(MyHelper.storeToken, {
      'fcm_token': fcmToken,
      'device_id': deviceId,
    });
    if (response.statusCode == 200) {
      sharedPref.write("FCM_TOKEN", true);
      debugPrint("FCM TOKEN onResponse: ${response.statusCode}");
    } else {
      debugPrint('Error sending FCM token: ${response.body}');
    }
  }

  Future<String> getDeviceId() async {
    String deviceId = 'Loading...';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        deviceId = iosDeviceInfo.identifierForVendor ?? '';
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        deviceId = androidDeviceInfo.id;
      }
      return deviceId;
    } catch (e) {
      return deviceId;
    }
  }

  Future<void> getServers() async {
    _apiDebouncer.call(() async {
      try {
        final response = await apiClient.getData(MyHelper.serverUrl);
        if (response.statusCode == 200) {
          ServerModel? serverModel = serverModelFromJson(response.body);
          if (serverModel.data != null) {
            serversList.assignAll(serverModel.data!);
          }
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    });
  }

  Future<void> getUsers() async {
    _apiDebouncer.call(() async {
      try {
        final response = await apiClient.getData(MyHelper.userUrl);
        if (response.statusCode == 200) {
        final UserModel userModel = userModelFromJson(response.body);
        user.value = userModel.data!;
        if (userModel.data != null &&
            userModel.data!.userPackageDetails != null &&
            userModel.data!.loginMode != "guest") {
          paymentInfo.value = userModel.data!.userPackageDetails;
          DateTime expirationDate = paymentInfo.value!.expiresAt!;
          DateTime currentDate = DateTime.parse(
              DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(
                  DateTime.now().toUtc().add(const Duration(hours: 6))));
          if (currentDate.isBefore(expirationDate) ||
              currentDate.isAtSameMomentAs(expirationDate)) {
            startSubscriptionTimer();
            updateSub(true);
          } else if (isSubscribed.value) {
            if (paymentInfo.value != null) {
              paymentInfo.value = null;
            }
            updateSub(false);
          }
        } else {
          if (paymentInfo.value != null) {
            paymentInfo.value = null;
          }
          if (isSubscribed.value) {
            updateSub(false);
          }
        }
        } else if (response.statusCode == 405 || response.statusCode == 401) {
          user.value = null;
          userData.write(MyHelper.bToken, '');
        }
      } catch (e) {
        debugPrint("Error user: $e");
      }
    });
  }

  Future<void> logOut() async {
    final response = await apiClient.postData(MyHelper.logoutUrl, {});
    if (response.statusCode == 200) {
      user.value = null;
      userData.write(MyHelper.bToken, '');
      update();
    }
  }

  List<String> calculateSavings(String previousCost, String currentCost,
      dynamic currentDays, dynamic previousDays) {
    double previousCostDouble = double.parse(previousCost);
    double currentCostDouble = double.parse(currentCost);
    double currentDaysDouble = currentDays.toDouble();
    double previousDaysDouble = previousDays.toDouble();

    double previousDailyCost = previousCostDouble / previousDaysDouble;

    double totalPreviousCostForCurrentDays =
        previousDailyCost * currentDaysDouble;

    double savingsAmount = totalPreviousCostForCurrentDays - currentCostDouble;

    double percentageSavings =
        (savingsAmount / totalPreviousCostForCurrentDays) * 100;

    String formattedSavingsAmount = savingsAmount.toStringAsFixed(2);
    String formattedPercentageSavings =
        '${percentageSavings.toStringAsFixed(2)}%';

    return [formattedSavingsAmount, formattedPercentageSavings];
  }

  //inAppSubscription
  final List<ProductDetails> product = <ProductDetails>[];
  final List<ProductId> productIds = <ProductId>[];
  var isSubscribed = false.obs;

  IApEngine iApEngine = IApEngine();

  Future<void> getProducts() async {
    iApEngine.inAppPurchase.purchaseStream.listen((event) {
      listenPurchases(event);
    });
    isSubscribed.value = userData.read(MyHelper.isAccountPremium) ?? false;
    bool isAvailable = await iApEngine.getIsAvailable();
    if (isAvailable) {
      try {
        var newValue = await iApEngine.queryProducts(productIds);
        product.addAll(newValue.productDetails);
        update();
      } catch (error) {
        debugPrint('Error querying products: $error');
      }
    }
  }

  Future<void> listenPurchases(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      for (PurchaseDetails purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.restored ||
            purchaseDetails.status == PurchaseStatus.purchased) {
          Map purchaseData = json
              .decode(purchaseDetails.verificationData.localVerificationData);

          if (purchaseData['acknowledge']) {
            updateSub(true);
          } else {
            if (Platform.isAndroid) {
              final InAppPurchaseAndroidPlatformAddition
                  androidPlatformAddition = iApEngine.inAppPurchase
                      .getPlatformAddition<
                          InAppPurchaseAndroidPlatformAddition>();

              await androidPlatformAddition
                  .consumePurchase(purchaseDetails)
                  .then((value) {
                updateSub(true);
              });
            }

            if (purchaseDetails.pendingCompletePurchase) {
              await iApEngine.inAppPurchase
                  .completePurchase(purchaseDetails)
                  .then((value) {
                updateSub(true);
              });
            }
          }
        }
      }
    } else {
      updateSub(false);
    }
  }

  void restoreSub() {
    iApEngine.inAppPurchase.restorePurchases();
  }

  void updateSub(bool value) {
    isSubscribed.value = value;
    userData.write(MyHelper.isAccountPremium, value);
    userData.write(MyHelper.removeAds, value);
    update();
  }

  bool _tryToPayUsingUddokta = false;

  bool get tryToPayUsingUddokta => _tryToPayUsingUddokta;

  void updateError({bool? isTrue}) {
    _tryToPayUsingUddokta = isTrue ?? false;
    update();
  }

  Future<ResponseModel> payUsingUddokta(
      String amount, int id, String packDuration) async {
    return convertCurrency(amount).then((value) async {
      Map<String, String> metadata = {
        'user_id': user.value!.id.toString(),
        'product_id': id.toString(),
        'pack_duration': packDuration,
      };

      String rawBody = createPaymentData(
        fullName: user.value!.name ?? '',
        email: user.value!.email ?? '',
        amount: value,
        metadata: metadata,
        redirectUrl: '${MyHelper.paymentBaseUrl}payment/success',
        returnType: '${MyHelper.paymentBaseUrl}payment/invoice_id',
        cancelUrl: '${MyHelper.paymentBaseUrl}payment/cancel',
        webhookUrl: '${MyHelper.paymentBaseUrl}payment/ipn',
      );
      Response response = await payUsingUddoktaClient(
          apiClient, MyHelper.createPaymentUrl,
          rawBody: rawBody);
      ResponseModel responseModel;
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"]) {
          String paymentUrl = responseData["payment_url"];
          responseModel = ResponseModel(
              responseData["status"], paymentUrl, response.statusCode);
        } else {
          responseModel =
              ResponseModel(false, response.body, response.statusCode);
        }
      } else {
        responseModel =
            ResponseModel(false, response.body, response.statusCode);
      }
      return responseModel;
    });
  }

  Future<ResponseModel> verifyPayment(
      String invoiceId, AuthController authController) async {
    String rawBody = verifyPaymentData(invoiceId: invoiceId);
    Response response = await payUsingUddoktaClient(
        apiClient, MyHelper.verifyPaymentUrl,
        rawBody: rawBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData["status"].toString().contains("COMPLETED")) {
        int packDuration = int.parse(responseData['metadata']['pack_duration']);
        DateTime expirationDate = DateTime.parse(responseData['date'])
            .add(Duration(days: packDuration * 30));
        String rawBody = savePaymentData(
            userId: responseData['metadata']['user_id'],
            invoiceId: responseData['invoice_id'],
            productId: responseData['metadata']['product_id'],
            amount: responseData['amount'],
            fee: responseData['fee'],
            chargedAmount: responseData['charged_amount'],
            paymentMethod: responseData['payment_method'],
            senderNumber: responseData['sender_number'],
            transactionId: responseData['transaction_id'],
            date: expirationDate.toString(),
            status: responseData['status']);
        responseModel = ResponseModel(true, rawBody, packDuration);
      } else {
        responseModel =
            ResponseModel(false, responseData["status"], response.statusCode);
      }
    } else {
      responseModel = ResponseModel(false, response.body, response.statusCode);
    }
    return responseModel;
  }

  Future<String> convertCurrency(String usdAmount) async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double exchangeRate = data['rates']['BDT'];
      double bdtAmount = double.parse(usdAmount) * exchangeRate;
      return bdtAmount.toStringAsFixed(2);
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  Future<Response> payUsingUddoktaClient(ApiClient apiClient, String url,
      {required String rawBody}) async {
    apiClient.updateHeader(isUddokta: true);
    return await apiClient.postData(url, rawBody, isRaw: true);
  }
}
