import 'dart:convert';
import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'navigation_data.dart';

class NavigationService {
  // RouteService와 호환되는 메서드 추가
  Future<List<NLatLng>> getRoute(double startLat, double startLng, double endLat, double endLng) async {
    try {
      print('🔥 NavigationService.getRoute 호출');

      // 기존 getNavigationData 메서드 활용
      final navData = await getNavigationData(startLat, startLng, endLat, endLng);

      // NavigationData에서 NLatLng 리스트로 변환
      List<NLatLng> routePoints = [];

      // fullRoute가 있다면 그것을 사용
      if (navData.fullRoute != null && navData.fullRoute!.isNotEmpty) {
        routePoints = navData.fullRoute!;
        print('🔥 fullRoute 사용: ${routePoints.length}개 포인트');
      } else {
        // fullRoute가 없다면 기존 방식으로 좌표 가져오기
        print('🔥 기존 방식으로 좌표 가져오기');
        final coordinates = await getRouteCoordinates(startLat, startLng, endLat, endLng);

        for (var coord in coordinates) {
          if (coord.containsKey('lat') && coord.containsKey('lng')) {
            routePoints.add(NLatLng(coord['lat']!, coord['lng']!));
          }
        }
        print('🔥 변환된 포인트 수: ${routePoints.length}');
      }

      // 최소한 시작점과 끝점은 보장
      if (routePoints.isEmpty) {
        print('🔥 경로가 비어있음, 기본 경로 생성');
        routePoints = [
          NLatLng(startLat, startLng),
          NLatLng(endLat, endLng),
        ];
      }

      return routePoints;

    } catch (e) {
      print('🔥 NavigationService.getRoute 실패: $e');

      // 실패시 직선 경로 반환
      return [
        NLatLng(startLat, startLng),
        NLatLng(endLat, endLng),
      ];
    }
  }

  Future<NavigationData> getNavigationData(double startLat, double startLng, double endLat, double endLng) async {
    final url = Uri.parse('${ApiConstants.navigationBaseUrl}startLat=$startLat&startLon=$startLng&endLat=$endLat&endLon=$endLng');

    print('🔥 요청 URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'Flutter App',
        },
      );

      print('🔥 응답 상태 코드: ${response.statusCode}');
      print('🔥 응답 본문: ${response.body}'); // 디버깅용

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('🔥 JSON 파싱 성공');
        print('🔥 디코딩된 데이터 키들: ${decoded.keys.toList()}'); // 디버깅용

        // NavigationData 객체 생성 및 파싱
        NavigationData navData = NavigationData();

        // 압축된 경로 데이터 파싱
        if (decoded.containsKey('usedFavoriteRouteVertices')) {
          print('🔥 usedFavoriteRouteVertices 파싱 시작');
          navData.parseCompressedRoute(decoded['usedFavoriteRouteVertices']);
          print('🔥 파싱된 경로 포인트 수: ${navData.fullRoute?.length ?? 0}');
        }

        // Features에서 안내 지점 파싱
        if (decoded.containsKey('features')) {
          print('🔥 features 파싱 시작');
          for (var feature in decoded['features']) {
            try {
              if (feature['geometry']['type'] == 'Point') {
                navData.steps.add(NavigationStep.fromFeature(feature));
              }
            } catch (e) {
              print('🔥 feature 파싱 오류: $e');
            }
          }
          print('🔥 파싱된 스텝 수: ${navData.steps.length}');
        }

        // 거리와 시간 정보 파싱
        if (decoded.containsKey('summary')) {
          print('🔥 summary 파싱 시작');
          var summary = decoded['summary'];
          navData.totalDistance = _parseToDouble(summary['distance']) ?? 0;
          navData.totalTime = _parseToDouble(summary['duration']) ?? 0;
          print('🔥 총 거리: ${navData.totalDistance}m, 총 시간: ${navData.totalTime}초');
        }

        // 목적지 설정
        navData.destination = NLatLng(endLat, endLng);

        return navData;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 요청 실패: $e');
      rethrow;
    }
  }

  // 안전한 숫자 파싱 헬퍼 메서드
  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('🔥 문자열을 double로 변환 실패: $value');
        return null;
      }
    }
    return null;
  }

  // 기존 메서드들 유지 (호환성을 위해)
  Future<String> getCoordinate(double startLat, double startLng, double endLat, double endLng) async {
    final url = Uri.parse('${ApiConstants.navigationBaseUrl}startLat=$startLat&startLon=$startLng&endLat=$endLat&endLon=$endLng');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter App',
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded.containsKey('usedFavoriteRouteVertices')) {
          return decoded['usedFavoriteRouteVertices'] as String;
        }
        return response.body; // 전체 JSON 반환
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 요청 실패: $e');
      rethrow;
    }
  }

  List<Map<String, double>> _decodeRouteVertices(String encodedRoute) {
    List<Map<String, double>> coordinates = [];

    try {
      List<String> segments = encodedRoute.split(':');

      if (segments.isNotEmpty) {
        List<String> startCoords = segments[0].split(',');
        if (startCoords.length == 2) {
          double startLat = double.parse(startCoords[0]) / 1000000;
          double startLng = double.parse(startCoords[1]) / 1000000;
          coordinates.add({'lat': startLat, 'lng': startLng});

          double currentLat = startLat;
          double currentLng = startLng;

          for (int i = 1; i < segments.length; i++) {
            List<String> deltaCoords = segments[i].split(',');
            if (deltaCoords.length == 2) {
              double deltaLat = double.parse(deltaCoords[0]) / 1000000;
              double deltaLng = double.parse(deltaCoords[1]) / 1000000;

              currentLat += deltaLat;
              currentLng += deltaLng;

              coordinates.add({'lat': currentLat, 'lng': currentLng});
            }
          }
        }
      }
    } catch (e) {
      print('🔥 경로 디코딩 실패: $e');
    }

    return coordinates;
  }

  Future<List<Map<String, double>>> getRouteCoordinates(double startLat, double startLng, double endLat, double endLng) async {
    try {
      final encodedRoute = await getCoordinate(startLat, startLng, endLat, endLng);
      return _decodeRouteVertices(encodedRoute);
    } catch (e) {
      print('경로 가져오기 실패: $e');
      return [];
    }
  }
}
