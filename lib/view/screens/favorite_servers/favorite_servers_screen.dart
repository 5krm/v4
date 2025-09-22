import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../ads/ads_helper.dart';
import '../../../controller/favorite_server_controller.dart';
import '../../../model/server_model.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/server_item_widget.dart';

class FavoriteServersScreen extends StatefulWidget {
  const FavoriteServersScreen({super.key});

  @override
  State<FavoriteServersScreen> createState() => _FavoriteServersScreenState();
}

class _FavoriteServersScreenState extends State<FavoriteServersScreen> {
  final FavoriteServerController favoriteServerController =
      Get.put(FavoriteServerController(apiClient: Get.find()));

  @override
  void initState() {
    super.initState();
    // Load favorite servers when screen opens
    favoriteServerController.getFavoriteServers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Favorite Servers',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: Obx(() {
          if (favoriteServerController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: MyColor.accent,
              ),
            );
          }

          if (favoriteServerController.favoriteServers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await favoriteServerController.getFavoriteServers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteServerController.favoriteServers.length,
              itemBuilder: (context, index) {
                final server = favoriteServerController.favoriteServers[index];
                return _buildServerItem(server, index);
              },
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          height: Get.find<AdsCallBack>().isBannerLoaded.value ? 50 : 0,
          color: MyColor.bg,
          child: AdsHelper().showBanner(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: MyColor.textSecondary,
          ),
          const SizedBox(height: 20),
          Text(
            'No Favorite Servers',
            style: outfitSemiBold.copyWith(
              color: MyColor.textPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your favorite VPN servers here for quick access',
            textAlign: TextAlign.center,
            style: outfitRegular.copyWith(
              color: MyColor.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to servers screen to add favorites
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Browse Servers',
              style: outfitSemiBold.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerItem(Server server, int index) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 15),
      child: ServerItemWidget(
        server: server,
        onTap: () {
          // Handle server selection (connect to VPN)
          // This would typically integrate with your VPN connection logic
        },
        showFavoriteButton: true,
        isFavorite: true,
        onFavoriteTap: () async {
          // Remove from favorites
          final success = await favoriteServerController
              .removeFavoriteServer(server.id as int);
          if (success) {
            // Show success message
            Get.snackbar(
              'Success',
              'Server removed from favorites',
              backgroundColor: MyColor.cardBg,
              colorText: MyColor.textPrimary,
            );
          } else {
            // Show error message
            Get.snackbar(
              'Error',
              'Failed to remove server from favorites',
              backgroundColor: MyColor.cardBg,
              colorText: MyColor.textPrimary,
            );
          }
        },
      ),
    );
  }
}
