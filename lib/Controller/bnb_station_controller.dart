import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';

class BnbStationController extends GetxController {
  final bnbchargeStation = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndCahrge();
  }

  Future<void> _loadUidAndCahrge() async {
    await loadBnbCharge();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadBnbCharge() async {
    isLoading.value = true;
    try {
      final rawHostCharge = await fetchHostCharge();
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
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchHostCharge() async {
    final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else{
      throw Exception('Failed to fetch hostCharge');
    }
  }
}