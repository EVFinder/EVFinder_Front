import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:evfinder_front/Controller/reserv_user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum ReserveType {
  create,
  update,
}

class ReservController extends GetxController {
  final contactController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  var type = ReserveType.create;

  String? uid;
  String? shareId;
  String? ownerUid;
  String? userName;
  String? reserveId;

  @override
  void onInit() {
    super.onInit();
    _loadUidandUsername();
    selectMode();
  }

  void selectMode() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if(arguments != null) {
      type = arguments['type'] ?? ReserveType.create;

      if(type == ReserveType.update) { //수정 모드인 경우
        final reservationData = arguments['reservation'] as Map<String, dynamic>;
        reserveId = reservationData['id']?.toString();
        shareId = reservationData['shareId']?.toString();
        ownerUid = reservationData['ownerUid']?.toString();

        contactController.text = reservationData['userPNumber'] ?? '';
        startController.text = reservationData['startTime'] ?? '';
        endController.text = reservationData['endTime'] ?? '';
      } else {
        shareId = arguments['id']?.toString();
        ownerUid = arguments['ownerUid']?.toString();
      }

    }
  }

  @override
  void dispose() {
    super.dispose();
    contactController.dispose();
    startController.dispose();
    endController.dispose();
  }
  Future<void> _loadUidandUsername() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    userName = prefs.getString('name');
  }

  Future <void> reserv(BuildContext context) async {
    final userPNumber = contactController.text;
    final startTime = startController.text;
    final endTime = endController.text;
    final headers = {'Content-Type': 'application/json'};

    if (userPNumber.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연락처와 시간을 모두 입력해주세요.')),
      );
      return;
    }

    String toUtcIso(String v) {
      final dt = DateTime.parse(v);
      return dt.toUtc().toIso8601String();
    }

    final startUtc = toUtcIso(startTime);
    final endUtc   = toUtcIso(endTime);

    final body = jsonEncode({
      'shareId': shareId,
      "ownerUid": ownerUid,
      'userName': userName,
      'userPNumber': userPNumber,
      'startTime': startUtc,
      'endTime': endUtc,
      'lat': 37.25
    });
    try {
      http.Response response;
      String successMessage;
      if(type == ReserveType.update) {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}/${reserveId}');
        response = await http.put(url, headers: headers, body: body);
        successMessage = '수정이 완료되었습니다.';
        if (Get.isRegistered<ReservUserController>()) {
          Get.find<ReservUserController>().loadreservCharge();
        }
      } else {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}');
        response = await http.post(url, headers: headers, body: body);
        successMessage = '예약이 완료되었습니다.';
      }
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }else {
        // 서버가 에러 메시지를 준다면 보여주기
        final msg = response.body.isNotEmpty ? response.body : '요청 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패(${response.statusCode}) : $msg')),
        );
      }
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
  }
}