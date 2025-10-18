import 'package:evfinder_front/Controller/MainPage/camera_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  var mapController = CameraController();
  Position? position;

  // 권한 요청 상태 관리
  static bool _isRequestingPermission = false;

  Future<bool> permission() async {
    // 이미 권한 요청 중이면 대기 후 현재 상태 반환
    if (_isRequestingPermission) {
      // 권한 요청이 완료될 때까지 대기
      while (_isRequestingPermission) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      // 대기 후 현재 권한 상태 반환
      return await Permission.location.isGranted;
    }

    try {
      _isRequestingPermission = true;
      // 현재 권한 상태 먼저 확인
      PermissionStatus currentStatus = await Permission.location.status;
      // 이미 허용된 경우
      if (currentStatus.isGranted) {
        return true;
      }
      // // 영구적으로 거부된 경우
      // if (currentStatus.isPermanentlyDenied) {
      //   await openAppSettings();
      //   return false;
      // }

      // 권한 요청
      Map<Permission, PermissionStatus> status = await [Permission.location].request();
      if (status[Permission.location]?.isGranted ?? false) {
        // 허용 시
        print('Location permission granted');
        return true;
      } else {
        // 거부 시
        print('Location permission denied');
        return false;
      }
    } catch (e) {
      print('Permission request error: $e');
      return false;
    } finally {
      _isRequestingPermission = false;
    }
  }

  Future<void> permissionCheck() async {
    try {
      // 권한 상태 확인 (허용이면 넘어가고, 거부면 권한 요청)
      PermissionStatus status = await Permission.location.status;
      if (status.isGranted) {
        print('Location permission already granted');
        // 이미 권한이 있으면 위치 정보 가져오기
        await getCurrentLocation();
        // Get.offAndToNamed(AppRoutes.login);
      } else {
        print('Location permission not granted, requesting...');
        bool granted = await permission();
        if (granted) {
          await getCurrentLocation();
        }
      }
    } catch (e) {
      print('Permission check error: $e');
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // 권한 확인 후 위치 가져오기
      if (!await Permission.location.isGranted) {
        print('Location permission not granted');
        return null;
      }
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }
      Position resultPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // 타임아웃 설정
      );
      position = resultPosition;
      print('Current location: ${position?.latitude}, ${position?.longitude}');
      return position;
    } catch (e) {
      print('위치 가져오기 실패: $e');
      return null;
    }
  }

  // 동기적으로 position에 접근하는 getter
  Position? get currentPosition => position;

  // 권한 상태 확인 메서드 (동기적)
  Future<bool> get hasLocationPermission async {
    return await Permission.location.isGranted;
  }

  // 위치 서비스 활성화 확인
  Future<bool> get isLocationServiceEnabled async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // 권한 요청 중인지 확인
  bool get isRequestingPermission => _isRequestingPermission;
}
