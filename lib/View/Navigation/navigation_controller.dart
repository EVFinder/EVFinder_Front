import 'package:evfinder_front/View/Navigation/navigation_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../Controller/permission_controller.dart';
import 'dart:async';
import 'navigation_data.dart';

class NavigationController extends GetxController {
  final NavigationService _navigationService = NavigationService();
  final PermissionController _permissionController = PermissionController();

  // Observable 변수들
  final Rx<NavigationData?> navigationData = Rx<NavigationData?>(null);
  final Rx<NLatLng?> currentLocation = Rx<NLatLng?>(null);
  final RxBool isNavigating = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentInstruction = ''.obs;
  final RxDouble distanceToNext = 0.0.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxString navigationStatus = '준비 중...'.obs; // 누락된 변수 추가

  Timer? _locationTimer;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void onInit() {
    super.onInit();
    _startLocationTracking();
  }

  @override
  void onClose() {
    stopNavigation();
    _positionSubscription?.cancel();
    super.onClose();
  }

  // 네비게이션 시작
  Future<void> startNavigation(double destLat, double destLng) async {
    try {
      print('=== startNavigation 시작 ===');
      print('목적지: $destLat, $destLng');

      isLoading.value = true;
      navigationStatus.value = '경로를 계산하는 중...';

      // 현재 위치 확인
      if (currentLocation.value == null) {
        print('현재 위치가 null이므로 위치 가져오기 시도');
        await getCurrentLocation();
      }

      if (currentLocation.value == null) {
        throw Exception('현재 위치를 확인할 수 없습니다');
      }

      print('현재 위치: ${currentLocation.value}');

      // NavigationService를 사용하여 경로 계산
      print('경로 계산 시작...');
      final route = await _navigationService.getRoute(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
        destLat,
        destLng,
      );

      print('계산된 경로 포인트 수: ${route.length}');
      if (route.isNotEmpty) {
        print('첫 번째 포인트: ${route.first}');
        print('마지막 포인트: ${route.last}');
      }

      if (route.isEmpty) {
        throw Exception('경로를 찾을 수 없습니다');
      }

      // NavigationData 생성
      final navData = NavigationData(
        fullRoute: route,
        destination: NLatLng(destLat, destLng),
        totalDistance: _calculateTotalDistance(route),
        totalTime: _calculateEstimatedTime(route),
      );

      print('NavigationData 생성 완료');
      print('총 거리: ${navData.totalDistance}m');
      print('예상 시간: ${navData.totalTime}초');

      // navigationData 설정
      navigationData.value = navData;
      print('navigationData.value 설정 완료: ${navigationData.value != null}');

      // 위치 추적 시작
      await _startLocationTracking();

      isNavigating.value = true;
      navigationStatus.value = '네비게이션이 시작되었습니다';

      print('=== startNavigation 완료 ===');

    } catch (e) {
      print('=== startNavigation 실패 ===');
      print('에러: $e');
      navigationStatus.value = '오류: ${e.toString()}';
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // 네비게이션 중지
  void stopNavigation() {
    isNavigating.value = false;
    _locationTimer?.cancel();
    _positionSubscription?.cancel();
    currentStepIndex.value = 0;
    currentInstruction.value = '';
    distanceToNext.value = 0.0;
    navigationStatus.value = '중지됨';
  }

  // 실시간 위치 추적
  Future<void> _startLocationTracking() async {
    try {
      _positionSubscription?.cancel(); // 기존 구독 취소

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // 5미터마다 업데이트
        ),
      ).listen((Position position) {
        _onLocationUpdate(NLatLng(position.latitude, position.longitude));
      });
    } catch (e) {
      print('위치 추적 시작 실패: $e');
    }
  }

  // 위치 업데이트 처리
  void _onLocationUpdate(NLatLng location) {
    currentLocation.value = location;

    if (!isNavigating.value || navigationData.value == null) return;

    // 경로 이탈 체크
    _checkRouteDeviation(location);

    // 다음 안내 지점 체크
    _checkNextStep(location);

    // 거리 업데이트
    _updateDistanceToNextStep();
  }

  // 경로 이탈 체크
  void _checkRouteDeviation(NLatLng location) {
    if (navigationData.value?.fullRoute?.isEmpty ?? true) return;

    double minDistance = double.infinity;
    for (NLatLng routePoint in navigationData.value!.fullRoute!) {
      double distance = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          routePoint.latitude,
          routePoint.longitude
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    if (minDistance > 100) {
      // 100m 이상 이탈
      Get.snackbar('경로 이탈', '경로에서 벗어났습니다. 경로를 재계산합니다.');
      recalculateRoute();
    }
  }

  // 다음 안내 지점 체크
  void _checkNextStep(NLatLng location) {
    if (navigationData.value?.steps.isEmpty ?? true) return;
    if (currentStepIndex.value >= navigationData.value!.steps.length) return;

    NavigationStep currentStep = navigationData.value!.steps[currentStepIndex.value];
    double distanceToStep = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        currentStep.position.latitude,
        currentStep.position.longitude
    );

    // 50m 이내 접근시 다음 단계로
    if (distanceToStep < 50) {
      currentStepIndex.value++;

      if (currentStepIndex.value < navigationData.value!.steps.length) {
        NavigationStep nextStep = navigationData.value!.steps[currentStepIndex.value];
        currentInstruction.value = nextStep.instruction;

        // 음성 안내 (TTS 구현 필요)
        _announceInstruction(nextStep.instruction);
      } else {
        // 목적지 도착
        currentInstruction.value = '목적지에 도착했습니다.';
        stopNavigation();
        Get.snackbar('도착', '목적지에 도착했습니다!');
      }
    }
  }

  // 다음 단계까지 거리 업데이트
  void _updateDistanceToNextStep() {
    if (currentLocation.value == null ||
        navigationData.value?.steps.isEmpty == true ||
        currentStepIndex.value >= navigationData.value!.steps.length) {
      distanceToNext.value = 0.0;
      return;
    }

    NavigationStep currentStep = navigationData.value!.steps[currentStepIndex.value];
    double distance = Geolocator.distanceBetween(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
        currentStep.position.latitude,
        currentStep.position.longitude
    );

    distanceToNext.value = distance;
  }

  // 경로 재계산
  Future<void> recalculateRoute() async {
    if (currentLocation.value == null || navigationData.value?.fullRoute?.isEmpty == true) return;

    // 목적지는 기존 경로의 마지막 지점
    NLatLng destination = navigationData.value!.fullRoute!.last;

    // 현재 위치에서 목적지까지 새 경로 계산
    await startNavigation(destination.latitude, destination.longitude);
  }

  // 음성 안내 (TTS 구현 필요)
  void _announceInstruction(String instruction) {
    print('🔊 음성 안내: $instruction');
    // TODO: TTS 라이브러리를 사용해서 음성 안내 구현
  }

  // 현재 위치 가져오기
  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      currentLocation.value = NLatLng(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('현재 위치를 가져올 수 없습니다: $e');
    }
  }

  // 거리 계산 헬퍼 메서드
  double _calculateTotalDistance(List<NLatLng> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // 예상 시간 계산 헬퍼 메서드 (평균 속도 40km/h 가정)
  double _calculateEstimatedTime(List<NLatLng> route) {
    double distance = _calculateTotalDistance(route);
    double averageSpeedKmh = 40.0; // 평균 속도 40km/h
    double timeInHours = distance / 1000.0 / averageSpeedKmh;
    return timeInHours * 3600; // 초 단위로 반환
  }

  // 편의 메서드들
  String get formattedDistance {
    if (distanceToNext.value < 1000) {
      return '${distanceToNext.value.round()}m';
    } else {
      return '${(distanceToNext.value / 1000).toStringAsFixed(1)}km';
    }
  }

  String get formattedTotalDistance {
    if (navigationData.value == null) return '0km';

    double km = navigationData.value!.totalDistance / 1000.0;
    return '${km.toStringAsFixed(1)}km';
  }

  String get formattedTotalTime {
    if (navigationData.value == null) return '0분';

    int minutes = (navigationData.value!.totalTime / 60).round();
    if (minutes < 60) {
      return '${minutes}분';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${hours}시간 ${remainingMinutes}분';
    }
  }

  // 기존 메서드 (호환성을 위해 유지)
  Future<void> getCoordinates(double endLat, double endLon) async {
    await startNavigation(endLat, endLon);
  }
}
