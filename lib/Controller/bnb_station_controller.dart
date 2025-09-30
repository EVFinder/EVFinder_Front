import 'dart:convert';
import 'package:evfinder_front/Controller/permission_controller.dart';
import 'package:evfinder_front/Controller/review_detail_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';
import 'package:geolocator/geolocator.dart';


class BnbStationController extends GetxController {
  final bnbchargeStation = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  final PermissionController locationController = PermissionController();
  Rx<Position?> userPosition = Rx<Position?>(null);
  RxDouble lat = 37.5665.obs;
  RxDouble lon = 126.9780.obs;
  RxDouble searchLat = 37.5665.obs;
  RxDouble searchLon = 126.9780.obs;

  @override
  void onInit() {
    super.onInit();
    loadBnbCharge(lat: lat.value, lon: lon.value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initLocation() async {
    try {
      Position? position = await locationController.getCurrentLocation();
      userPosition.value = position;
      lat.value = position!.latitude;
      lon.value = position.longitude;
      print('위치 로드 성공: ${lat.value}, ${lon.value}');
    } catch (e) {
      print('위치 로드 실패: $e');
    }
  }

  Future<void> loadBnbCharge({double? lat, double? lon}) async {
    isLoading.value = true;
    try {
      final rawHostCharge = await fetchHostCharge(lat: lat, lon: lon);
      bnbchargeStation.assignAll(
        rawHostCharge.map(
              (e) =>
          {
            "id" : e['id']?.toString() ?? '알 수 없음',
            "address": e['address']?.toString() ?? '알 수 없음',
            "lat": e['lat'] ?? 0.0,
            "lon": e['lon'] ?? 0.0,
            "hostName": e['hostName']?.toString() ?? '알 수 없음',
            "hostContact": e['hostContact']?.toString() ?? '알 수 없음',
            "stationName": e['stationName']?.toString() ?? '알 수 없음',
            "chargerType": e['chargerType']?.toString() ?? '알 수 없음',
            "power": e['power']?.toString() ?? '알 수 없음',
            "pricePerHour": e['pricePerHour'] ?? 0.0,
            "status": e['status']?.toString() ?? '알 수 없음',
            "ownerUid": e['ownerUid']?.toString() ?? '알 수 없음,'
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchHostCharge({double? lat, double? lon}) async {
    var urlString = '${ApiConstants.chargerbnbApiUrl}/all';

    if(lat != null && lon != null) {
      urlString += '?lat=$lat&lon=$lon&radiusKm=20';
    }

    final url = Uri.parse(urlString);
    print("URL: $url");
    final response = await http.get(url);

    print("서버 응답 코드: ${response.statusCode}");
    print("서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else{
      throw Exception('Failed to fetch hostCharge');
    }
  }

}