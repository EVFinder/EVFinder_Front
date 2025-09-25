import 'package:evfinder_front/Model/ev_charger.dart';
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
    isLoading.value = true;
    try {
      final rawFavorites = await FavoriteService.fetchFavoriteStatus(uid.value);
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

  Future<void> removeFavorite(String statId) async {
    final success = await FavoriteService.removeFavorite(uid.value, statId);
    if (success) {
      favoriteStations.removeWhere((station) => station['id'] == statId);
    }
  }

  Future<void> addFavorite(EvCharger evCharger) async {
    final success = await FavoriteService.addFavorite(uid.value, evCharger);
    if (success) {
      // 중복 체크 후 추가
      if (!favoriteStations.any((station) => station['id'] == evCharger.id)) {
        favoriteStations.add({
          "name": evCharger.name ?? '알 수 없음',
          "address": evCharger.addr ?? '주소 없음',
          "id": evCharger.id ?? '',
          "lat": evCharger.lat ?? 0.0,
          "lon": evCharger.lon ?? 0.0,
          "chargers": evCharger.evchargerDetail ?? [], // 또는 evCharger.chargers
          "isFavorite": true,
        });
      }
    }
  }
}
