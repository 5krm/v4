import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/api/api_client.dart';
import '../model/favorite_server_model.dart';
import '../model/server_model.dart';
import '../utils/my_helper.dart';

class FavoriteServerController extends GetxController {
  final ApiClient apiClient;

  FavoriteServerController({required this.apiClient});

  var favoriteServers = <Server>[].obs;
  var isLoading = false.obs;
  var isCheckingFavorite = false.obs;

  /// Get all favorite servers for the current user
  Future<void> getFavoriteServers() async {
    try {
      isLoading.value = true;
      final response = await apiClient.getData(MyHelper.favoriteServersUrl);

      if (response.statusCode == 200) {
        final favoriteServersModel =
            favoriteServersModelFromJson(response.body);
        favoriteServers.value = favoriteServersModel.data ?? [];
      }
    } catch (e) {
      // Handle error
      print('Error fetching favorite servers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a server to favorites
  Future<bool> addFavoriteServer(int serverId) async {
    try {
      final response = await apiClient.postData(
        MyHelper.addFavoriteServerUrl,
        {'server_id': serverId},
      );

      if (response.statusCode == 200) {
        // Refresh the favorite servers list
        await getFavoriteServers();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding favorite server: $e');
      return false;
    }
  }

  /// Remove a server from favorites
  Future<bool> removeFavoriteServer(int serverId) async {
    try {
      final response = await apiClient.postData(
        MyHelper.removeFavoriteServerUrl,
        {'server_id': serverId},
      );

      if (response.statusCode == 200) {
        // Refresh the favorite servers list
        await getFavoriteServers();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing favorite server: $e');
      return false;
    }
  }

  /// Check if a server is in favorites
  Future<bool> isFavorite(int serverId) async {
    try {
      isCheckingFavorite.value = true;
      final response = await apiClient.postData(
        MyHelper.isFavoriteServerUrl,
        {'server_id': serverId},
      );

      if (response.statusCode == 200) {
        final isFavoriteModel = isFavoriteModelFromJson(response.body);
        return isFavoriteModel.data?.isFavorite ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    } finally {
      isCheckingFavorite.value = false;
    }
  }
}
