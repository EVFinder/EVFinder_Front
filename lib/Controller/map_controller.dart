import 'package:evfinder_front/Controller/camera_controller.dart';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../Model/ev_charger.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import '../Model/search_chargers.dart';
import '../Service/ev_charger_service.dart';
import '../Service/marker_service.dart';

class MapController extends GetxController {
  late NaverMapController nMapController;
  final BoxController boxController = BoxController();

  // late CameraController cameraController;
  RxList<NMarker> markers = <NMarker>[].obs;
  RxList<EvCharger> chargers = <EvCharger>[].obs;
  RxBool isMapReady = false.obs;
  final PermissionController locationController = PermissionController();
  final CameraController cameraController = CameraController();
  RxBool isLocationLoaded = false.obs;
  Rx<Position?> userPosition = Rx<Position?>(null);
  RxDouble lat = 37.5665.obs;
  RxDouble lon = 126.9780.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   print('PermissionController 초기화됨');
  //   // 초기화 시 실행할 코드들
  //   initializeLocation();
  // }

  Future<void> initializeLocation() async {
    try {
      Position? position = await locationController.getCurrentLocation();
      userPosition.value = position;
      lat.value = position!.latitude;
      lon.value = position.longitude;
      isLocationLoaded.value = true;
    } catch (e) {
      print('위치 가져오기 실패: $e');
      isLocationLoaded.value = true; // 실패해도 지도는 보여주기
    }
  }

  Future<void> fetchMyChargers(BuildContext context, SearchChargers? result) async {
    if (result != null) {
      // 기존 마커 제거
      if (markers.isNotEmpty) {
        MarkerService.removeMarkers(nMapController, markers);
      }
      await fetchChargers(double.parse(result.y), double.parse(result.x));
      // ✅ 이 부분이 빠져있었음!
      await loadMarkers(context, chargers);

      cameraController.moveCameraPosition(double.parse(result.y), double.parse(result.x), nMapController);
    } else {
      await fetchChargers(lat.value, lon.value);
      await loadMarkers(context, chargers);
    }
  }

  Future<void> fetchChargers(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchNearbyChargers(lat, lon);
    chargers.value = resultChargers;
    chargers.refresh();
    update();
  }

  Future<void> loadMarkers(BuildContext context, List<EvCharger> chargers) async {
    try {
      final newMarkers = await MarkerService.generateMarkers(context, chargers, nMapController);
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
}
