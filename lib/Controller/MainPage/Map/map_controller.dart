import 'dart:async';

import 'package:evfinder_front/Controller/MainPage/camera_controller.dart';
import 'package:evfinder_front/Controller/MainPage/permission_controller.dart';
import 'package:evfinder_front/Service/weather_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Model/ev_charger.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import '../../../Model/search_chargers.dart';
import '../../../Model/weather.dart';
import '../../../Service/ev_charger_service.dart';
import '../../../Service/marker_service.dart';

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

  //  현재 카메라 위치 (메모리에만 저장)
  RxDouble currentCameraLat = 37.5665.obs;
  RxDouble currentCameraLng = 126.9780.obs;
  RxDouble currentZoom = 15.0.obs;
  RxBool hasSetInitialPosition = false.obs; //  초기 위치 설정 여부

  // 지도 중심점 좌표
  RxDouble mapCenterLat = 37.5665.obs;
  RxDouble mapCenterLng = 126.9780.obs;

  Timer? _searchTimer;

  // 초기화 메서드
  Future<void> initializeLocation() async {
    print(' initializeLocation 시작');
    cameraMoved.value = false;
    isInitialLoad.value = true;

    try {
      Position? position = await locationController.getCurrentLocation();
      userPosition.value = position;
      lat.value = position!.latitude;
      lon.value = position.longitude;

      //  항상 현재 위치로 카메라 위치 설정
      currentCameraLat.value = position.latitude;
      currentCameraLng.value = position.longitude;
      hasSetInitialPosition.value = true;

      print(' 위치 설정 완료: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print(' 위치 가져오기 실패: $e');
      // 기본 위치 사용
      print(' 기본 위치 사용: ${currentCameraLat.value}, ${currentCameraLng.value}');
    } finally {
      isLocationLoaded.value = true;
      print(' initializeLocation 완료');
    }
  }

  // 맵 준비 완료 처리
  Future<void> onMapReady(BuildContext context, NaverMapController mapController) async {
    print(' onMapReady 시작');
    nMapController = mapController;

    //  현재 카메라 위치를 실제 사용자 위치로 설정
    if (userPosition.value != null) {
      currentCameraLat.value = userPosition.value!.latitude;
      currentCameraLng.value = userPosition.value!.longitude;
      print(' 사용자 위치로 카메라 위치 설정: ${currentCameraLat.value}, ${currentCameraLng.value}');
    }

    try {
      await fetchMyChargers(context, null);
      print(' 초기 충전소 검색 성공');
    } catch (e) {
      print(' 초기 충전소 검색 실패: $e');
      // 초기 로딩 실패해도 맵은 준비됨
    }

    isMapReady.value = true;
    isInitialLoad.value = false;
    cameraMoved.value = false;
    print(' onMapReady 완료');
  }

  // 카메라 이동 완료 처리
  void onCameraIdle() async {
    //  사용자 제스처로 움직였을 때만 버튼 표시
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

    //  제스처 플래그 초기화
    isUserGesture.value = false;
  }

  // 버튼 표시 여부 계산
  bool get shouldShowRefreshButton => isMapReady.value && cameraMoved.value && !isInitialLoad.value;

  // fetchMyChargers 메서드
  Future<void> fetchMyChargers(BuildContext context, SearchChargers? result) async {
    try {
      print(' fetchMyChargers 시작');
      await clearAllMarkers();

      double targetLat, targetLon;

      if (result != null) {
        print(' 검색 결과로 이동: ${result.y}, ${result.x}');
        targetLat = double.parse(result.y);
        targetLon = double.parse(result.x);

        //  검색 결과로 이동시 카메라 위치 업데이트
        currentCameraLat.value = targetLat;
        currentCameraLng.value = targetLon;

        cameraController.moveCameraPosition(targetLat, targetLon, nMapController);
        cameraMoved.value = false;
      } else {
        //  현재 저장된 카메라 위치 사용
        targetLat = currentCameraLat.value;
        targetLon = currentCameraLng.value;
        print(' 현재 카메라 위치 사용: $targetLat, $targetLon');
      }

      //  날씨와 충전소 검색을 분리해서 처리
      try {
        weather.value = await fetchWeather(targetLat, targetLon);
        print(' 날씨 정보 가져오기 성공');
      } catch (e) {
        print(' 날씨 정보 가져오기 실패: $e');
        // 날씨 실패해도 충전소는 계속 검색
      }

      try {
        await fetchChargers(targetLat, targetLon);
        print(' 충전소 검색 성공: ${chargers.length}개');
      } catch (e) {
        print(' 충전소 검색 실패: $e');
        throw e; // 충전소 검색 실패는 전체 실패로 처리
      }

      try {
        if (context != null && chargers.isNotEmpty) {
          await loadMarkers(context, chargers);
          print(' 마커 로딩 성공');
        } else if (chargers.isEmpty) {
          print(' 검색된 충전소가 없음');
        }
      } catch (e) {
        print(' 마커 로딩 실패: $e');
        // 마커 로딩 실패해도 데이터는 있으므로 에러 던지지 않음
      }

      print(' fetchMyChargers 완료');
    } catch (e) {
      print(' fetchMyChargers 전체 실패: $e');

      // 🔥 사용자에게 구체적인 에러 메시지 표시
      String errorMessage = '충전소 검색에 실패했습니다.';
      if (e.toString().contains('네트워크')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('시간')) {
        errorMessage = '요청 시간이 초과되었습니다.';
      }

      Get.snackbar('검색 실패', errorMessage, duration: Duration(seconds: 3), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);

      throw e; // 에러를 다시 던져서 호출하는 곳에서도 알 수 있게 함
    }
  }

  // 수동 새로고침 처리
  Future<void> refreshCurrentLocation(BuildContext context) async {
    try {
      cameraMoved.value = false;

      // final center = await getCurrentMapCenter();
      await fetchChargersByLocation(context, currentCameraLat.value, currentCameraLng.value);

      //  새로고침시 카메라 위치 업데이트
      final cameraPosition = await nMapController.getCameraPosition();
      currentCameraLat.value = cameraPosition.target.latitude;
      currentCameraLng.value = cameraPosition.target.longitude;
      currentZoom.value = cameraPosition.zoom;

      // Get.snackbar('새로고침 완료', '현재 위치 기준으로 충전소를 새로 검색했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      print('새로고침 실패: $e');
      Get.snackbar('새로고침 실패', '충전소 검색 중 오류가 발생했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }

  // 나머지 메서드들은 동일...
  Future<void> fetchChargers(double lat, double lon) async {
    print(' fetchChargers 호출: $lat, $lon');
    try {
      List<EvCharger> resultChargers = await EvChargerService.fetchNearbyChargers(lat, lon);

      chargers.value = resultChargers;
      chargers.refresh();
      update();

      print(' 충전소 데이터 업데이트 완료');
    } catch (e) {
      print(' fetchChargers 에러: $e');
      throw e;
    }
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
