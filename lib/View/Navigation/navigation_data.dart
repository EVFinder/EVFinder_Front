import 'package:flutter_naver_map/flutter_naver_map.dart';

class NavigationData {
  List<NLatLng>? fullRoute;
  NLatLng? destination;
  double totalDistance;
  double totalTime;
  double estimatedTime; // 추가된 속성
  List<NavigationStep> steps;

  NavigationData({
    this.fullRoute,
    this.destination,
    this.totalDistance = 0,
    this.totalTime = 0,
    this.estimatedTime = 0, // 추가
    List<NavigationStep>? steps,
  }) : steps = steps ?? [];

  // 압축된 경로 데이터를 파싱하는 메서드
  void parseCompressedRoute(String encodedRoute) {
    try {
      List<NLatLng> routePoints = [];
      List<String> segments = encodedRoute.split(':');

      if (segments.isNotEmpty) {
        List<String> startCoords = segments[0].split(',');
        if (startCoords.length == 2) {
          double startLat = double.parse(startCoords[0]) / 1000000;
          double startLng = double.parse(startCoords[1]) / 1000000;
          routePoints.add(NLatLng(startLat, startLng));

          double currentLat = startLat;
          double currentLng = startLng;

          for (int i = 1; i < segments.length; i++) {
            List<String> deltaCoords = segments[i].split(',');
            if (deltaCoords.length == 2) {
              double deltaLat = double.parse(deltaCoords[0]) / 1000000;
              double deltaLng = double.parse(deltaCoords[1]) / 1000000;

              currentLat += deltaLat;
              currentLng += deltaLng;

              routePoints.add(NLatLng(currentLat, currentLng));
            }
          }
        }
      }

      fullRoute = routePoints;
      print('🔥 압축 경로 파싱 완료: ${routePoints.length}개 포인트');

    } catch (e) {
      print('🔥 압축 경로 파싱 실패: $e');
      fullRoute = [];
    }
  }
}

class NavigationStep {
  NLatLng position;
  String instruction;
  String direction;
  int distance;
  int duration;

  NavigationStep({
    required this.position,
    required this.instruction,
    required this.direction,
    required this.distance,
    required this.duration,
  });

  static NavigationStep fromFeature(Map<String, dynamic> feature) {
    try {
      var geometry = feature['geometry'];
      var properties = feature['properties'] ?? {};

      return NavigationStep(
        position: NLatLng(
          _parseDouble(geometry['coordinates'][1]) ?? 0.0,
          _parseDouble(geometry['coordinates'][0]) ?? 0.0,
        ),
        instruction: properties['description']?.toString() ?? '직진',
        direction: properties['turnType']?.toString() ?? 'STRAIGHT',
        distance: _parseInt(properties['distance']) ?? 0,
        duration: _parseInt(properties['duration']) ?? 0,
      );
    } catch (e) {
      print('🔥 NavigationStep.fromFeature 파싱 오류: $e');
      return NavigationStep(
        position: NLatLng(0, 0),
        instruction: '직진',
        direction: 'STRAIGHT',
        distance: 0,
        duration: 0,
      );
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
