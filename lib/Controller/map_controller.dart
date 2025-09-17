import 'package:evfinder_front/Controller/camera_controller.dart';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Model/ev_charger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Service/favorite_service.dart';
import '../Service/ev_charger_service.dart';
import '../Service/location_service.dart';
import '../Service/marker_service.dart';
import '../View/Widget/charger_detail_card.dart';

class MapController extends GetxController {
  late NaverMapController nMapController;
  final BoxController boxController = BoxController();
  late CameraController cameraController;
  RxList<NMarker> markers = <NMarker>[].obs;
  RxList<EvCharger> chargers = <EvCharger>[].obs;
  RxBool isMapReady = false.obs;
  final PermissionController locationController = PermissionController();
  RxBool isLocationLoaded = false.obs;
  Rx<Position?> userPosition = Rx<Position?>(null);
  RxDouble lat = 37.5665.obs;
  RxDouble lon = 126.9780.obs;

  Future<void> initializeLocation() async {
    try {
      Position? position = await locationController.getCurrentLocation();
      userPosition.value = position;
      isLocationLoaded.value = true;
    } catch (e) {
      print('위치 가져오기 실패: $e');
      isLocationLoaded.value = true; // 실패해도 지도는 보여주기
    }
  }

  Future<void> fetchMyChargers(BuildContext context, dynamic result) async {
    if (result != null) {
      // 기존 마커 제거
      if (markers.isNotEmpty) {
        MarkerService.removeMarkers(nMapController, markers);
      }

      await fetchChargers(lat.value, lon.value);

      // ✅ 이 부분이 빠져있었음!
      await loadMarkers(context, chargers);

      cameraController.moveCameraPosition(
          double.parse(result.y),
          double.parse(result.x),
          nMapController
      );
    } else {
      await fetchChargers(lat.value, lon.value);
      await loadMarkers(context, chargers.value); // ✅ chargers -> chargers.value
    }
  }

  Future<void> fetchChargers(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchChargers(lat, lon);
    chargers.value = resultChargers;
  }

  Future<void> loadMarkers(BuildContext context, List<EvCharger> chargers) async {
    try {
      final newMarkers = await MarkerService.generateMarkers(
          chargers,
          nMapController,
              (EvCharger charger) {
            // 여기서 모달 띄우기
            showChargerDetail(context, charger);
          }
      );
      markers.value = newMarkers;
      print(markers);
      for (var marker in markers) {
        try {
          await nMapController.addOverlay(marker);
        } catch (e) {
          print("마커 추가 실패: ${marker.info.id}, 이유: $e");
        }
      }
    } catch (e) {
      print("마커 로딩 실패: $e");
    }
  }


  void showChargerDetail(BuildContext context, EvCharger charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ChargerDetailCard(
              charger: charger,
              isFavorite: false, // 또는 적절한 값
              // uid: uid,
            );
          },
        );
      },
    );
  }

}
