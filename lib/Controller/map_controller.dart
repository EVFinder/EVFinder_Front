import 'dart:async';

import 'package:evfinder_front/Controller/camera_controller.dart';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:evfinder_front/Service/weather_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/ev_charger.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import '../Model/search_chargers.dart';
import '../Model/weather.dart';
import '../Service/ev_charger_service.dart';
import '../Service/marker_service.dart';

class MapController extends GetxController {
  late NaverMapController nMapController;
  final BoxController boxController = BoxController();

  RxList<NMarker> markers = <NMarker>[].obs;
  RxList<EvCharger> chargers = <EvCharger>[].obs;
  RxBool isMapReady = false.obs;
  RxBool isLocationLoaded = false.obs;
  RxBool cameraMoved = false.obs;
  RxBool isInitialLoad = true.obs;
  RxBool isUserGesture = false.obs; // 🔥x<We 사용자 제스처 여부
  Rx<Weather> weather = Weather(main: "Clear", description: "Clear Sky", temperature: 23.0, feelsLike: 23.0, humidity: 23).obs;
  RxString address = ''.obs;

  final PermissionController locationController = PermissionController();
  final CameraController cameraController = CameraController();
  Rx<Position?> userPosition = Rx<Position?>(null);
  RxDouble lat = 37.5665.obs;
  RxDouble lon = 126.9780.obs;

  // 🔥 현재 카메라 위치 (메모리에만 저장)
  RxDouble currentCameraLat = 37.5665.obs;
  RxDouble currentCameraLng = 126.9780.obs;
  RxDouble currentZoom = 15.0.obs;
  RxBool hasSetInitialPosition = false.obs; // 🔥 초기 위치 설정 여부

  // 지도 중심점 좌표
  RxDouble mapCenterLat = 37.5665.obs;
  RxDouble mapCenterLng = 126.9780.obs;

  Timer? _searchTimer;

  // 초기화 메서드
  Future<void> initializeLocation() async {
    cameraMoved.value = false;
    isInitialLoad.value = true;

    try {
      Position? position = await locationController.getCurrentLocation();
      userPosition.value = position;
      lat.value = position!.latitude;
      lon.value = position.longitude;

      // 🔥 처음 실행시에만 현재 위치로 카메라 위치 설정
      if (!hasSetInitialPosition.value) {
        currentCameraLat.value = position.latitude;
        currentCameraLng.value = position.longitude;
        hasSetInitialPosition.value = true;
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
    } finally {
      isLocationLoaded.value = true;
    }
  }

  // 맵 준비 완료 처리
  Future<void> onMapReady(BuildContext context, NaverMapController mapController) async {
    nMapController = mapController;

    await fetchMyChargers(context, null);
    isMapReady.value = true;
    isInitialLoad.value = false;
    cameraMoved.value = false;
  }

  // 카메라 이동 완료 처리
  void onCameraIdle() async {
    // 🔥 사용자 제스처로 움직였을 때만 버튼 표시
    if (isMapReady.value && !isInitialLoad.value && isUserGesture.value) {
      cameraMoved.value = true;

      // 현재 카메라 위치 업데이트 (메모리에만)
      try {
        final cameraPosition = await nMapController.getCameraPosition();
        currentCameraLat.value = cameraPosition.target.latitude;
        currentCameraLng.value = cameraPosition.target.longitude;
        currentZoom.value = cameraPosition.zoom;

        print('카메라 위치 업데이트: ${currentCameraLat.value}, ${currentCameraLng.value}');
      } catch (e) {
        print('카메라 위치 업데이트 실패: $e');
      }
    }

    // 🔥 제스처 플래그 초기화
    isUserGesture.value = false;
  }

  // 버튼 표시 여부 계산
  bool get shouldShowRefreshButton => isMapReady.value && cameraMoved.value && !isInitialLoad.value;

  // fetchMyChargers 메서드
  Future<void> fetchMyChargers(BuildContext? context, SearchChargers? result) async {
    try {
      await clearAllMarkers();

      double targetLat, targetLon;

      if (result != null) {
        targetLat = double.parse(result.y);
        targetLon = double.parse(result.x);

        // 🔥 검색 결과로 이동시 카메라 위치 업데이트
        currentCameraLat.value = targetLat;
        currentCameraLng.value = targetLon;

        cameraController.moveCameraPosition(targetLat, targetLon, nMapController);
        cameraMoved.value = false;
      } else {
        // 🔥 현재 저장된 카메라 위치 사용
        targetLat = currentCameraLat.value;
        targetLon = currentCameraLng.value;
      }

      weather.value = await fetchWeather(targetLat, targetLon);
      await fetchChargers(targetLat, targetLon);

      if (context != null) {
        await loadMarkers(context, chargers);
      }
    } catch (e) {
      print('fetchMyChargers 실패: $e');
    }
  }

  // 수동 새로고침 처리
  Future<void> refreshCurrentLocation(BuildContext context) async {
    try {
      cameraMoved.value = false;

      final center = await getCurrentMapCenter();
      await fetchChargersByLocation(context, center.latitude, center.longitude);

      // 🔥 새로고침시 카메라 위치 업데이트
      final cameraPosition = await nMapController.getCameraPosition();
      currentCameraLat.value = cameraPosition.target.latitude;
      currentCameraLng.value = cameraPosition.target.longitude;
      currentZoom.value = cameraPosition.zoom;

      Get.snackbar('새로고침 완료', '현재 위치 기준으로 충전소를 새로 검색했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      print('새로고침 실패: $e');
      Get.snackbar('새로고침 실패', '충전소 검색 중 오류가 발생했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }

  // 나머지 메서드들은 동일...
  Future<void> fetchChargers(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchNearbyChargers(lat, lon);
    chargers.value = resultChargers;
    chargers.refresh();
    update();
  }

  Future<void> loadMarkers(BuildContext context, List<EvCharger> chargers) async {
    try {
      await clearAllMarkers();
      final newMarkers = await MarkerService.generateMarkers(context, chargers, nMapController);

      List<NMarker> addedMarkers = [];
      for (var marker in newMarkers) {
        try {
          await nMapController.addOverlay(marker);
          addedMarkers.add(marker);
          print("마커 추가 성공: ${marker.info.id}");
        } catch (e) {
          print("마커 추가 실패: ${marker.info.id}, 이유: $e");
        }
      }

      markers.value = addedMarkers;
      markers.refresh();
      print("총 ${addedMarkers.length}개 마커 추가됨");
    } catch (e) {
      print("마커 로딩 실패: $e");
    }
  }

  Future<void> clearAllMarkers() async {
    try {
      if (markers.isNotEmpty) {
        for (var marker in markers) {
          try {
            await nMapController.deleteOverlay(marker.info);
          } catch (e) {
            print("마커 삭제 실패: ${marker.info.id}, 이유: $e");
          }
        }
        markers.clear();
        markers.refresh();
      }
    } catch (e) {
      print("마커 클리어 실패: $e");
    }
  }

  Future<void> fetchChargersByLocation(BuildContext context, double lt, double lg) async {
    try {
      print('위치 기준 충전소 검색: $lt, $lg');
      lat.value = lt;
      lon.value = lg;
      await fetchMyChargers(context, null);
    } catch (e) {
      print('충전소 검색 실패: $e');
    }
  }

  void updateMapCenter(BuildContext context, double lat, double lng) async {
    mapCenterLat.value = lat;
    mapCenterLng.value = lng;
  }

  Future<NLatLng> getCurrentMapCenter() async {
    final cameraPosition = await nMapController.getCameraPosition();
    return cameraPosition.target;
  }

  Future<Weather> fetchWeather(double lat, double lon) async {
    Weather weather = await WeatherService.fetchWeather(lat, lon);
    address.value = await coorToAddr(lat, lon);
    return weather;
  }

  Future<String> coorToAddr(double lat, double lon) async {
    String address = await WeatherService.chageCoorToAddr(lat, lon);

    return address;
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
}
