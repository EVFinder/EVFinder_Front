import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';


class RegisterChargeController extends GetxController {
  final addrController = TextEditingController();
  final detailaddrController = TextEditingController();
  final phoneController = TextEditingController();
  final chargeNameContrller = TextEditingController();
  final chargeTypeController = TextEditingController();
  final statController = TextEditingController();
  final powerController = TextEditingController();
  final priceContoller = TextEditingController();

  final Rx<double?> lat = Rx<double?>(null);
  final Rx<double?> lon = Rx<double?>(null);

  final selectedStat = Rxn<String>();
  final Map<String, String> statOptions = {
    'available': '사용 가능',
    'unavailable': '불가능',
  };

  String? uid;
  String? userName;
  @override
  void onInit() {
    super.onInit();
    _loadUid();
  }
  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid'); // 로그인 시 setString('uid', uid)로 저장했던 값
    userName = prefs.getString('name');
  }

  @override
  void dispose() {
    addrController.dispose();
    detailaddrController.dispose();
    phoneController.dispose();
    chargeNameContrller.dispose();
    chargeTypeController.dispose();
    statController.dispose();
    powerController.dispose();
    priceContoller.dispose();
  }
  Future<void> openPostcode() async {
    await Get.to(() => KpostalView(
      callback: (Kpostal result) {
        addrController.text = result.roadAddress.isNotEmpty
            ? result.roadAddress
            : result.address;
        lat.value = result.latitude;
        lon.value = result.longitude;

      },
    ));
  }

  Future <void> register(BuildContext context) async {
    final address = '${addrController.text.trim()} ${detailaddrController.text.trim()}'.trim();
    final hostContact = phoneController.text;
    final stationName = chargeNameContrller.text;
    final chargerType = chargeTypeController.text;
    final power = powerController.text;
    final pricePerHour = priceContoller.text;
    final status = selectedStat.value;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.chargerbnbApiUrl}/${uid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'address': address,
          'lat': lat.value,
          'lon': lon.value,
          'hostName':userName,
          'hostContact':hostContact,
          'stationName':stationName,
          'chargerType': chargerType,
          'power': power,
          'pricePerHour':pricePerHour,
          'status':status})
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('등록 완료!')),
        );
      }else {
        // 서버가 에러 메시지를 준다면 보여주기
        final msg = response.body.isNotEmpty ? response.body : '요청 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패(${response.statusCode}) : $msg')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
  }
}