import 'dart:convert';
import 'dart:math' as math;
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
        routePoints = [NLatLng(startLat, startLng), NLatLng(endLat, endLng)];
      }

      return routePoints;
    } catch (e) {
      print('🔥 NavigationService.getRoute 실패: $e');

      // 실패시 직선 경로 반환
      return [NLatLng(startLat, startLng), NLatLng(endLat, endLng)];
    }
  }


  Future<NavigationData> getNavigationData(double startLat, double startLng, double endLat, double endLng) async {
    final url = Uri.parse('${ApiConstants.navigationBaseUrl}startLat=$startLat&startLon=$startLng&endLat=$endLat&endLon=$endLng');

    print('🔥 요청 URL: $url');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'User-Agent': 'Flutter App'});

      print('🔥 응답 상태 코드: ${response.statusCode}');
      print('🔥 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('🔥 JSON 파싱 성공');
        print('🔥 디코딩된 데이터 키들: ${decoded.keys.toList()}');

        NavigationData navData = NavigationData();

        // 🔥 Features에서 좌표 추출 (새로 추가)
        List<NLatLng> featureCoords = [];
        if (decoded.containsKey('features')) {
          print('🔥 features에서 좌표 추출 시작');
          featureCoords = extractCoordinatesFromFeatures(decoded['features']);
          print('🔥 Features에서 추출된 좌표 수: ${featureCoords.length}');

          // Features에서 추출한 좌표를 fullRoute로 설정
          if (featureCoords.isNotEmpty) {
            navData.fullRoute = featureCoords;
            print('🔥 Features 좌표를 fullRoute로 설정');
          }

          // 기존 스텝 파싱도 유지
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

        // 압축된 경로 데이터 파싱 (Features에서 좌표를 못 가져왔을 때만)
        if (navData.fullRoute == null || navData.fullRoute!.isEmpty) {
          if (decoded.containsKey('usedFavoriteRouteVertices')) {
            print('🔥 usedFavoriteRouteVertices 파싱 시작');
            navData.parseCompressedRoute(decoded['usedFavoriteRouteVertices']);
            print('🔥 압축 경로에서 파싱된 포인트 수: ${navData.fullRoute?.length ?? 0}');
          }
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
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'User-Agent': 'Flutter App'});

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

    print('🔥 인코딩된 경로: $encodedRoute');

    try {
      List<String> segments = encodedRoute.split(':');
      print('🔥 세그먼트 수: ${segments.length}');

      if (segments.isNotEmpty) {
        List<String> startCoords = segments[0].split(',');
        print('🔥 시작 좌표 원본: ${segments[0]}');

        if (startCoords.length == 2) {
          double rawLat = double.parse(startCoords[0]);
          double rawLng = double.parse(startCoords[1]);

          print('🔥 파싱된 원본 lat: $rawLat, lng: $rawLng');

          // 여러 스케일 팩터로 테스트
          List<double> scaleFactors = [1000000, 100000, 10000000, 1000, 10000];

          for (double factor in scaleFactors) {
            double testLat = rawLat / factor;
            double testLng = rawLng / factor;
            print('🔥 스케일 $factor: ($testLat, $testLng)');
          }

          // 올바른 스케일 팩터 찾기 (한국 좌표 범위: 위도 33-43, 경도 124-132)
          double scaleFactor = 1000000; // 기본값

          // 각 스케일로 테스트해서 한국 범위에 맞는 것 찾기
          for (double factor in scaleFactors) {
            double testLat = rawLat / factor;
            double testLng = rawLng / factor;

            // 한국 좌표 범위 체크
            if (testLat >= 33 && testLat <= 43 && testLng >= 124 && testLng <= 132) {
              scaleFactor = factor;
              print('✅ 올바른 스케일 팩터 발견: $factor');
              break;
            }
          }

          double startLat = rawLat / scaleFactor;
          double startLng = rawLng / scaleFactor;

          coordinates.add({'lat': startLat, 'lng': startLng});
          print('🔥 첫 번째 좌표 추가: ($startLat, $startLng)');

          double currentLat = startLat;
          double currentLng = startLng;

          for (int i = 1; i < segments.length; i++) {
            List<String> deltaCoords = segments[i].split(',');
            if (deltaCoords.length == 2) {
              double rawDeltaLat = double.parse(deltaCoords[0]);
              double rawDeltaLng = double.parse(deltaCoords[1]);

              double deltaLat = rawDeltaLat / scaleFactor;
              double deltaLng = rawDeltaLng / scaleFactor;

              currentLat += deltaLat;
              currentLng += deltaLng;

              coordinates.add({'lat': currentLat, 'lng': currentLng});

              if (i <= 3) {
                // 처음 몇 개만 로그
                print('🔥 세그먼트[$i] 누적 좌표: ($currentLat, $currentLng)');
              }
            }
          }
        }
      }
    } catch (e) {
      print('🔥 경로 디코딩 실패: $e');
    }

    print('🔥 디코딩된 좌표 수: ${coordinates.length}');
    if (coordinates.isNotEmpty) {
      print('🔥 첫 번째 디코딩 좌표: ${coordinates.first}');
      print('🔥 마지막 디코딩 좌표: ${coordinates.last}');
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

  List<NLatLng> extractCoordinatesFromFeatures(List<dynamic> features) {
    List<NLatLng> coords = [];

    for (var feature in features) {
      if (feature['geometry'] != null) {
        var geometry = feature['geometry'];

        if (geometry['type'] == 'LineString' && geometry['coordinates'] != null) {
          var coordinates = geometry['coordinates'] as List;
          for (var coord in coordinates) {
            if (coord is List && coord.length >= 2) {
              double lng = coord[0].toDouble();
              double lat = coord[1].toDouble();
              coords.add(NLatLng(lat, lng));
              print('🔥 Feature LineString 좌표: ($lat, $lng)');
            }
          }
        } else if (geometry['type'] == 'Point' && geometry['coordinates'] != null) {
          var coord = geometry['coordinates'] as List;
          if (coord.length >= 2) {
            double lng = coord[0].toDouble();
            double lat = coord[1].toDouble();
            coords.add(NLatLng(lat, lng));
            print('🔥 Feature Point 좌표: ($lat, $lng)');
          }
        }
      }
    }

    return coords;
  }
}
