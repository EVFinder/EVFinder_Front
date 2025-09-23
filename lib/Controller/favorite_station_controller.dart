import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/favorite_service.dart';

class FavoriteStationController extends GetxController {
  final favoriteStations = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndFavorites();
  }

  Future<void> _loadUidAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await loadFavoriteStations();
  }

  // Future<void> loadFavoriteStations() async{
  //   isLoading.value = true;
  //
  //   try {
  //     final rawFavorites = await FavoriteService.fetchFavoritesWithStat(uid: uid.value);
  //     favoriteStations.assignAll(rawFavorites.map((e) => {
  //       "name": e['name']?.toString() ?? '알 수 없음',
  //       "addr": e['addr']?.toString() ?? '주소 없음',
  //       "useTime": e['useTime']?.toString() ?? '',
  //       "stat": e['stat'] ?? 0,
  //       "statId": e['statId'],
  //       "distance": e['distance'] != null
  //           ? "${double.parse(e['distance'].toString()).toStringAsFixed(1)} km"
  //           : '',
  //       "isFavorite": true,
  //     }));
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> loadFavoriteStations() async {
    isLoading.value = true;

    try {
      final rawFavorites = await FavoriteService.fetchFavorites(uid.value);
      favoriteStations.assignAll(
        rawFavorites.map(
          (e) => {
            "name": e['name']?.toString() ?? '알 수 없음',
            "address": e['address']?.toString() ?? '주소 없음',
            "id": e['id']?.toString() ?? '',
            "lat": e['lat'] ?? 0.0,
            "lon": e['lon'] ?? 0.0,
            "chargers": e['chargers'] ?? [],
            "isFavorite": true,
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFavoriteStations() async {
    // final success = await FavoriteService.removeFavorite(uid.value, statId);
  }

  Future<void> toggleFavorite(int index) async {
    final statId = favoriteStations[index]['id'];
    final success = await FavoriteService.removeFavorite(uid.value, statId);
    if (success) {
      favoriteStations.removeAt(index);
    }
  }
}
