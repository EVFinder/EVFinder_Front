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
  String addressname = '서울특별시 중구 세종대로 110';


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

  // Future<void> fetchMyChargers(BuildContext context, dynamic result) async {
  //   if (result != null && result is SearchChargers) {
  //     // 새 리스트로 fetch
  //     if (_markers.isNotEmpty) {
  //       MarkerService.removeMarkers(_nMapController, _markers);
  //     }
  //     addressname = result.addressName;
  //     await fetchChargers(addressname);
  //     // 마커 새로 로딩
  //     _loadMarkers(_chargers); // 이 부분 꼭 필요!
  //     cameraController.moveCameraPosition(double.parse(result.y), double.parse(result.x), _nMapController);
  //   } else {
  //     if (isLocationLoaded && locationController.position != null) {
  //       final addressResultName = LocationService.changeGPStoAddressName(locationController.position!.latitude, locationController.position!.longitude);
  //       addressname = await addressResultName;
  //     }
  //     await fetchChargers(addressname);
  //   }
  // }
  //
  // Future<void> fetchChargers(String addressName) async {
  //   final chargers = EvChargerService.fetchChargers(addressName); // ✅ 임시 query
  //   _chargers = await chargers;
  // }

  // Future<void> _loadMarkers(List<EvCharger> chargers) async {
  //   _markers = await MarkerService.generateMarkers(chargers, context, _nMapController);
  //   for (var marker in _markers) {
  //     try {
  //       await _nMapController.addOverlay(marker);
  //       await MarkerService.addMarkersToMap(_nMapController, _markers);
  //     } catch (e) {
  //       print("마커 추가 실패: ${marker.info.id}, 이유: $e");
  //     }
  //   }
  // }
}
