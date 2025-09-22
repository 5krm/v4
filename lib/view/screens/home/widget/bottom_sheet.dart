import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/home_controller.dart';
import '../../../../controller/favorite_server_controller.dart';
import '../../../../utils/app_layout.dart';
import '../../../../utils/my_font.dart';
import '../../../../utils/my_helper.dart';
import '../../../widgets/my_snake_bar.dart';
import '../../../widgets/server_item_widget.dart';

class ServerBottomSheet extends StatelessWidget {
  final Function onSelected;

  const ServerBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();
    if (homeController.serversList.isEmpty) {
      homeController.getServers();
    }

    return Container(
      width: AppLayout.getScreenWidth(context),
      height: context.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildModernHeader(),

          // Search Bar
          _buildSearchBar(),

          const SizedBox(height: 20),

          // Server List
          Expanded(
            child: Obx(
              () => homeController.serversList.isNotEmpty
                  ? _buildServerList(homeController)
                  : const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Text(
            'Location',
            style: outfitBold.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search Location',
              style: outfitMedium.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(HomeController homeController) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: homeController.serversList.length +
          1, // +1 for "All Countries" header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Auto/United States server (featured)
          return _buildFeaturedServer(homeController);
        }

        final serverIndex = index - 1;
        final server = homeController.serversList[serverIndex];
        return _buildServerItem(server, homeController);
      },
    );
  }

  Widget _buildFeaturedServer(HomeController homeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "All Countries" Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'All Countries',
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerItem(server, HomeController homeController) {
    // ignore: unused_local_variable
    final isSelected =
        homeController.selectedServer.value?.vpnCountry == server.vpnCountry;

    return ServerItemWidget(
      server: server,
      onTap: () {
        if (server.accessType == "premium" &&
            homeController.isSubscribed.value) {
          Navigator.pop(Get.context!);
          onSelected(server);
        } else if (server.accessType == "free") {
          Navigator.pop(Get.context!);
          onSelected(server);
        } else {
          MySnakeBar.showSnakeBar(
              "Need Subscribe!", "Subscribe & use Premium server!");
        }
      },
      showFavoriteButton: true,
      onFavoriteTap: () async {
        final favoriteController = Get.find<FavoriteServerController>();
        final serverId = server.id as int;

        // Check current favorite status
        final isCurrentlyFavorite =
            await favoriteController.isFavorite(serverId);

        if (isCurrentlyFavorite) {
          // Remove from favorites
          await favoriteController.removeFavoriteServer(serverId);
          Get.snackbar(
            'Removed',
            'Server removed from favorites',
            backgroundColor: const Color(0xFF0A0E1A),
            colorText: Colors.white,
          );
        } else {
          // Add to favorites
          await favoriteController.addFavoriteServer(serverId);
          Get.snackbar(
            'Added',
            'Server added to favorites',
            backgroundColor: const Color(0xFF0A0E1A),
            colorText: Colors.white,
          );
        }
      },
    );
  }

}
