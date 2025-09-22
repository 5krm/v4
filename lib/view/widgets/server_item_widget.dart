import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_server_controller.dart';
import '../../model/server_model.dart';
import '../../utils/my_color.dart';
import '../../utils/my_font.dart';
import '../../utils/my_helper.dart';

class ServerItemWidget extends StatefulWidget {
  final Server server;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ServerItemWidget({
    super.key,
    required this.server,
    this.onTap,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  State<ServerItemWidget> createState() => _ServerItemWidgetState();
}

class _ServerItemWidgetState extends State<ServerItemWidget> {
  late bool _isFavorite;
  late FavoriteServerController favoriteServerController;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    favoriteServerController = Get.find<FavoriteServerController>();
  }

  @override
  Widget build(BuildContext context) {
    final ping =
        '${(25 + (widget.server.vpnCountry?.length ?? 0) * 3)}ms'; // Simulate ping

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColor.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MyColor.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Flag - try to load from network, fallback to emoji
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: MyColor.glassBorder,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: widget.server.country?.icon != null
                    ? Image.network(
                        _getImageUrl(widget.server.country!.icon!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _getCountryEmoji(
                              widget.server.vpnCountry ?? '');
                        },
                      )
                    : _getCountryEmoji(widget.server.vpnCountry ?? ''),
              ),
            ),
            const SizedBox(width: 16),

            // Server Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.server.vpnCountry ?? '',
                    style: outfitSemiBold.copyWith(
                      color: MyColor.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ping,
                    style: outfitMedium.copyWith(
                      color: MyColor.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Signal Strength Indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final signalStrength =
                    (widget.server.vpnCountry?.length ?? 0) % 4 + 1;
                return Container(
                  width: 3,
                  height: 8 + (index * 4),
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: index < signalStrength
                        ? MyColor.success
                        : MyColor.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),

            const SizedBox(width: 16),

            // Favorite Button
            if (widget.showFavoriteButton) ...[
              GestureDetector(
                onTap: () async {
                  // Toggle favorite status
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });

                  // Call the provided callback
                  widget.onFavoriteTap?.call();
                },
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? MyColor.warning : MyColor.textSecondary,
                  size: 24,
                ),
              ),
            ] else ...[
              // Selection Indicator (for non-favorite view)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MyColor.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getImageUrl(String iconPath) {
    // Check if the icon path is already a complete URL
    if (iconPath.startsWith('http://') || iconPath.startsWith('https://')) {
      return iconPath;
    }
    // If it's a relative path, combine with base URL
    return "${MyHelper.baseUrl}$iconPath";
  }

  Widget _getCountryEmoji(String countryName) {
    // Simple mapping for common countries
    final countryEmojis = {
 

    };

    return Center(
      child: Text(
        countryEmojis[countryName] ?? '🌍',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
