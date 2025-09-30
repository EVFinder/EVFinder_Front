import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';

class AddChargeController extends GetxController {
  final hostchargeStation = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndCahrge();
  }

  Future<void> _loadUidAndCahrge() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await loadHostCharge();
  }

 @override
 void dispose() {
   super.dispose();
 }

  Future<void> loadHostCharge() async {
    isLoading.value = true;

    try {
      final rawHostCharge = await fetchHostCharge(uid.value);
      hostchargeStation.assignAll(
        rawHostCharge.map(
            (e) =>
                {
                  "address": e['address']?.toString() ?? '알 수 없음',
                  "lat": e['lat'] ?? 0.0,
                  "lon": e['lon'] ?? 0.0,
                  "hostName": e['hostName']?.toString() ?? '알 수 없음',
                  "id": e['id']?.toString() ?? '알 수 없음', //shareId
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

  static Future<List<Map<String, dynamic>>> fetchHostCharge(String uid) async {
    final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/${uid}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else{
      throw Exception('Failed to fetch hostCharge');
    }
  }
}