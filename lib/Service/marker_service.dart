import 'package:evfinder_front/Controller/MainPage/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/ev_charger.dart';
import '../View/Widget/BnB/charger_detail_card.dart';
import 'ev_charger_service.dart';
import 'favorite_service.dart'; // 또는 상대경로 맞게 수정

class MarkerService {
  static CameraController cameraController = CameraController();
  static Set<String> _addedMarkerIds = {}; // ID 추적용
  static RxList<EvCharger> focusCharger = <EvCharger>[].obs;

  static Future<List<NMarker>> generateMarkers(BuildContext context, List<EvCharger> chargers, NaverMapController nMapController) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid') ?? '';

    return chargers.map((charger) {
      final marker = NMarker(
        id: charger.id,
        position: NLatLng(charger.lat, charger.lon),
        caption: NOverlayCaption(text: charger.name),
      );

      marker.setOnTapListener((NMarker marker) async {
        cameraController.moveCameraPosition(charger.lat, charger.lon, nMapController);

        // final statIds = await FavoriteService.getFavoriteStatIds(uid);
        //
        // // 디버깅용 출력
        // print("📌 charger.statId = ${charger.id} (${charger.id.runtimeType})");
        // // print("📋 Favorite statIds = $statIds");
        //
        // final isFavorite = statIds.contains(charger.id.toString());
        await fetchOneBuildingCharger(charger.lat, charger.lon);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return ChargerDetailCard(
                  charger: charger,
                  // isFavorite: isFavorite, // 또는 적절한 값
                );
              },
            );
          },
        );

        // showModalBottomSheet(
        //   context: context,
        //   isScrollControlled: true,
        //   builder: (context) {
        //     return StatefulBuilder(
        //       builder: (context, setModalState) {
        //         // bool _isFavorite = isFavorite;
        //         return Text("sdf");
        //         // return ChargerDetailCard(
        //         //   charger: charger,
        //         //   isFavorite: _isFavorite,
        //         //   uid: uid,
        //         //   onFavoriteToggle: () async {
        //         //     if (_isFavorite) {
        //         //       await FavoriteService.removeFavorite(uid, charger.statId);
        //         //     } else {
        //         //       await FavoriteService.addFavorite(uid, charger);
        //         //     }
        //         //     setModalState(() {
        //         //       _isFavorite = !_isFavorite;
        //         //     });
        //         //   },
        //         // );
        //       },
        //     );
        //   },
        // );
      });

      return marker; // ❗❗ 여기 반드시 필요함
    }).toList();
  }

  static Future<void> addMarkersToMap(NaverMapController controller, List<NMarker> markers) async {
    print("마커 추가 시작");
    for (var marker in markers) {
      try {
        await controller.addOverlay(marker);
        _addedMarkerIds.add(marker.info.id);
      } catch (e) {
        print("마커 추가 실패: ${marker.info.id}, 이유: $e");
      }
    }
  }

  static Future<void> removeMarkers(NaverMapController controller, List<NMarker> markers) async {
    for (var marker in List.from(markers)) {
      if (_addedMarkerIds.contains(marker.info.id)) {
        try {
          await controller.deleteOverlay(marker.info);
          _addedMarkerIds.remove(marker.info.id); // 삭제된 것 제거
        } catch (e) {
          print("마커 삭제 실패: ${marker.info.id}, 이유: $e");
        }
      } else {
        print("이미 삭제된 마커 또는 등록되지 않은 마커: ${marker.info.id}");
      }
    }
    markers.clear();
  }

  static Future<void> fetchOneBuildingCharger(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchOneBuildingChargers(lat, lon);
    focusCharger.clear();
    focusCharger.value = resultChargers;
  }

  // void showChargerDetail(BuildContext context, EvCharger charger, bool isFavorite) async {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           return ChargerDetailCard(
  //             charger: focusCharger[0],
  //             isFavorite: isFavorite, // 또는 적절한 값
  //             // uid: uid,
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
