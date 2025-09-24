import 'dart:convert';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/ev_charger.dart';
import '../constants/api_constants.dart';

class FavoriteService {
  /// 즐겨찾기 추가
  static Future<bool> addFavorite(String uid, EvCharger charger) async {
    final url = Uri.parse('${ApiConstants.favoriteApiBaseUrl}/add/$uid');
    final body = {
      "id": charger.id,
      "name": charger.name,
      "address": charger.addr,
      "lat": charger.lat,
      "lon": charger.lon,
      "chargers": charger.evchargerDetail
          .map(
            (detail) => {
              "stationId": detail.stationId,
              "chargerId": detail.chargerId,
              "status": detail.status,
              "isAvailable": detail.isAvailable, // 또는 적절한 필드명
            },
          )
          .toList(),
    };
    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
    print('[DEBUG] 응답 코드: ${response.statusCode}');
    print('[DEBUG] 응답 내용: ${response.body}');
    return response.statusCode == 200;
  }

  /// 즐겨찾기 목록 조회
  static Future<List<Map<String, dynamic>>> fetchFavorites(String uid) async {
    final url = Uri.parse('${ApiConstants.favoriteApiBaseUrl}/list/$uid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch favorites');
    }
  }


  static Future<bool> removeFavorite(String uid, String statId) async {
    final url = Uri.parse('${ApiConstants.favoriteApiBaseUrl}/delete/$uid/$statId');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }


  // 임시값 (서울)
  static double userLat = 37.5665;
  static double userLng = 126.9780;


  static Future<List<Map<String, dynamic>>> fetchFavoritesWithStat({required String uid}) async {
    if (await Permission.location.isGranted) {
      var permissionController = Get.find<PermissionController>();
      await permissionController.getCurrentLocation();
      userLat = permissionController.position!.latitude;
      userLng = permissionController.position!.longitude;
    }

    final url = Uri.parse(
      '${ApiConstants.favoriteApiBaseUrl}/global/listWithStat'
      '?uid=$uid&lat=$userLat&lng=$userLng',
    );

    final response = await http.get(url);
    print('[DEBUG] 응답: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic> && body.containsKey('favorites')) {
        final list = List<Map<String, dynamic>>.from(body['favorites']);

        return list.map((e) {
          final rawDistance = e['distance'];
          final parsedDistance = (rawDistance is num) ? rawDistance : double.tryParse(rawDistance.toString()) ?? 0.0;

          final rawStat = e['stat'];
          final parsedStat = (rawStat is int) ? rawStat : int.tryParse(rawStat.toString()) ?? -1;

          return {...e, 'distance': parsedDistance.toStringAsFixed(1), 'stat': parsedStat};
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to fetch updated favorite chargers');
    }
  }

  static Future<int> fetchStat(String statId) async {
    final url = Uri.parse('${ApiConstants.evApiBaseUrl}/stat?statId=$statId');
    final response = await http.get(url);

    print('[DEBUG] 요청 URL: $url');
    print('[DEBUG] 응답: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return int.tryParse(json['stat'].toString()) ?? -1;
    } else {
      throw Exception('Failed to fetch stat for $statId');
    }
  }

  static Future<List<String>> getFavoriteStatIds(String uid) async {
    final url = Uri.parse('${ApiConstants.favoriteApiBaseUrl}/list/$uid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final favorites = List<Map<String, dynamic>>.from(json);
        // final Map<String, dynamic> json = jsonDecode(response.body);
        // final List<dynamic> favorites = json[json];
        return favorites.map((e) => e['id'].toString()).toList();
      } else {
        print("서버 응답 에러: ${response.statusCode}");
        return []; // 실패 시에도 빈 리스트 반환
      }
    } catch (e) {
      print("statId 받아오기 실패: $e");
      return []; // 네트워크 오류 등 실패 시도 처리
    }
  }

  static Future<bool> updateStat(String uid, String statId, int stat) async {
    final url = Uri.parse('${ApiConstants.favoriteApiBaseUrl}/updateStat');

    final body = {"uid": uid, "statId": statId, "stat": stat};

    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));

    return response.statusCode == 200;
  }
}
