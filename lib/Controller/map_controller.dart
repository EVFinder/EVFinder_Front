import 'dart:async';

import 'package:evfinder_front/Controller/camera_controller.dart';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  RxBool cameraMoved = false.obs;
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
    } catch (e) {
      print('위치 가져오기 실패: $e');
    } finally {
      isLocationLoaded.value = true;
      cameraMoved.value = false;
    }
  }

  // 🔥 개선된 fetchMyChargers 메서드
  Future<void> fetchMyChargers(BuildContext context, SearchChargers? result) async {
    try {
      // 1. 먼저 기존 마커들을 완전히 제거
      await clearAllMarkers();

      double targetLat, targetLon;

      if (result != null) {
        targetLat = double.parse(result.y);
        targetLon = double.parse(result.x);

        // 카메라 이동
        cameraController.moveCameraPosition(targetLat, targetLon, nMapController);
      } else {
        targetLat = lat.value;
        targetLon = lon.value;
      }

      // 2. 새로운 충전소 데이터 가져오기
      await fetchChargers(targetLat, targetLon);

      // 3. 새로운 마커들 로드
      await loadMarkers(context, chargers);
    } catch (e) {
      print('fetchMyChargers 실패: $e');
    } finally {
      cameraMoved.value = false;
    }
  }

  Future<void> fetchChargers(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchNearbyChargers(lat, lon);
    chargers.value = resultChargers;
    chargers.refresh();
    update();
  }

  // 🔥 개선된 loadMarkers 메서드
  Future<void> loadMarkers(BuildContext context, List<EvCharger> chargers) async {
    try {
      // 혹시 남아있을 수 있는 마커들 한번 더 제거
      await clearAllMarkers();

      // 새로운 마커들 생성
      final newMarkers = await MarkerService.generateMarkers(context, chargers, nMapController);

      // 마커들을 지도에 추가
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

      // 성공적으로 추가된 마커들만 저장
      markers.value = addedMarkers;
      markers.refresh();

      print("총 ${addedMarkers.length}개 마커 추가됨");
    } catch (e) {
      print("마커 로딩 실패: $e");
    }
  }

  // Future<void> fetchMyChargers(BuildContext context, SearchChargers? result) async {
  //   if (result != null) {
  //     // 기존 마커 제거
  //     if (markers.isNotEmpty) {
  //       MarkerService.removeMarkers(nMapController, markers);
  //     }
  //     await fetchChargers(double.parse(result.y), double.parse(result.x));
  //     // ✅ 이 부분이 빠져있었음!
  //     await loadMarkers(context, chargers);
  //
  //     cameraController.moveCameraPosition(double.parse(result.y), double.parse(result.x), nMapController);
  //   } else {
  //     if (markers.isNotEmpty) {
  //       MarkerService.removeMarkers(nMapController, markers);
  //     }
  //     await fetchChargers(lat.value, lon.value);
  //     await loadMarkers(context, chargers);
  //   }
  // }

  // Future<void> loadMarkers(BuildContext context, List<EvCharger> chargers) async {
  //   try {
  //     final newMarkers = await MarkerService.generateMarkers(context, chargers, nMapController);
  //     markers.value = newMarkers;
  //     print(markers);
  //     for (var marker in markers) {
  //       try {
  //         await nMapController.addOverlay(marker);
  //       } catch (e) {
  //         print("마커 추가 실패: ${marker.info.id}, 이유: $e");
  //       }
  //     }
  //   } catch (e) {
  //     print("마커 로딩 실패: $e");
  //   }
  // }

  // 🔥 모든 마커를 완전히 제거하는 메서드
  Future<void> clearAllMarkers() async {
    try {
      if (markers.isNotEmpty) {
        // 지도에서 마커들 제거
        for (var marker in markers) {
          try {
            await nMapController.deleteOverlay(marker.info);
          } catch (e) {
            print("마커 삭제 실패: ${marker.info.id}, 이유: $e");
          }
        }

        // 리스트 완전히 초기화
        markers.clear();
        markers.refresh();
      }
    } catch (e) {
      print("마커 클리어 실패: $e");
    }
  }

  //----------------------------------------------------------------

  // 지도 중심점 좌표
  RxDouble mapCenterLat = 37.5665.obs;
  RxDouble mapCenterLng = 126.9780.obs;

  // 클릭한 지점 좌표
  RxDouble clickedLat = 0.0.obs;
  RxDouble clickedLng = 0.0.obs;

  // 🔥 개선된 fetchChargersByLocation 메서드
  Future<void> fetchChargersByLocation(BuildContext context, double lt, double lg) async {
    try {
      print('위치 기준 충전소 검색: $lt, $lg');

      // 좌표 업데이트
      lat.value = lt;
      lon.value = lg;

      // 기존 마커 제거 후 새로운 충전소 검색
      await fetchMyChargers(context, null);
    } catch (e) {
      print('충전소 검색 실패: $e');
    }
  }

  // 🔥 지도 중심점 업데이트 (디바운싱 추가)
  Timer? _searchTimer;

  void updateMapCenter(BuildContext context, double lat, double lng) async {
    mapCenterLat.value = lat;
    mapCenterLng.value = lng;
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setDouble('lat', lat);
    // prefs.setDouble('lon', lng);

    // 기존 타이머 취소
    _searchTimer?.cancel();

    // 0.8초 후에 검색 실행 (사용자가 드래그를 멈췄을 때)
    _searchTimer = Timer(Duration(milliseconds: 800), () {
      fetchChargersByLocation(context, lat, lng);
    });
  }

  // 🔥 수동으로 현재 중심점 기준 새로고침
  Future<void> refreshCurrentLocation(BuildContext context) async {
    try {
      final center = await getCurrentMapCenter();
      await fetchChargersByLocation(context, center.latitude, center.longitude);

      Get.snackbar('새로고침 완료', '현재 위치 기준으로 충전소를 새로 검색했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      print('새로고침 실패: $e');
      Get.snackbar('새로고침 실패', '충전소 검색 중 오류가 발생했습니다.', duration: Duration(seconds: 2), backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }

  // 현재 지도 중심점 좌표 직접 가져오기
  Future<NLatLng> getCurrentMapCenter() async {
    final cameraPosition = await nMapController.getCameraPosition();
    return cameraPosition.target;
  }

  void cameraMoveCompleted(BuildContext context) async {
    final cameraPosition = await nMapController.getCameraPosition();
    final centerLat = cameraPosition.target.latitude;
    final centerLng = cameraPosition.target.longitude;

    print('지도 중심점: $centerLat, $centerLng');

    // 컨트롤러에 저장
    updateMapCenter(context, centerLat, centerLng);
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }

  // // 지도 클릭 처리
  // void onMapTapped(double lat, double lng) {
  //   clickedLat.value = lat;
  //   clickedLng.value = lng;
  //
  //   print('클릭한 위치: $lat, $lng');
  //
  //   // 클릭한 위치에 마커 추가하거나 다른 작업 수행
  //   // addClickMarker(lat, lng);
  // }

  // // 클릭한 위치에 마커 추가
  // void addClickMarker(double lat, double lng) async {
  //   // 기존 클릭 마커 제거
  //   // await removeClickMarker();
  //
  //   // 새 마커 생성
  //   final marker = NMarker(
  //     id: 'click_marker',
  //     position: NLatLng(lat, lng),
  //     caption: NOverlayCaption(text: '선택한 위치'),
  //   );
  //
  //   // 마커를 지도에 추가
  //   await nMapController.addOverlay(marker);
  // }

  // 클릭 마커 제거
  // Future<void> removeClickMarker() async {
  //   try {
  //     final overlay = await nMapController.deleteOverlay('click_marker');
  //     if (overlay != null) {
  //       await nMapController.deleteOverlay(overlay.info);
  //     }
  //   } catch (e) {
  //     print('마커 제거 실패: $e');
  //   }
  // }
}
