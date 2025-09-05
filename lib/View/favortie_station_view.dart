import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/Favorite_Station_controller.dart';


class FavoriteStationView extends GetView<FavoriteStationController> {
  const FavoriteStationView({super.key});
  static String route = "/favorite";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기 충전소')),
      body: Obx(() {
        if (controller.isLoading.value) { //controller.isLoading.value 상태가 true일 경우 로딩
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.favoriteStations.isEmpty) { //controller.isLoading.value 상태가 비어있으면 없습니다.
          return const Center(child: Text("즐겨찾기 목록이 존재하지 않습니다."));
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: controller.favoriteStations.length,
              itemBuilder: (context, index) {
                final station = controller.favoriteStations[index];
                return ListtileChargestarWidget(
                  stationName: station['name'],
                  stationAddress: station['addr'],
                  operatingHours: station['useTime'] ?? '',
                  chargerStat: station['stat'],
                  distance: station['distance'] ?? '',
                  isFavorite: station['isFavorite'],
                  onFavoriteToggle: () => controller.toggleFavorite(index),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.loadFavoriteStations,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
