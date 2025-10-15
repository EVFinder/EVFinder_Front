import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:evfinder_front/Controller/reserv_user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservController extends GetxController {
  final contactController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  bool isUpdate = false;

  String? uid;
  String? shareId;
  String? ownerUid;
  String? userName;
  String? reserveId;

  @override
  void onInit() {
    super.onInit();
    _loadUidandUsername();
  }

  void _resetState() {
    isUpdate = false;
    reserveId = null;
    shareId = null;
    ownerUid = null;

    contactController.clear();
    startController.clear();
    endController.clear();
  }

  void selectMode() {
    print('select Mode 실행');
    final arguments = Get.arguments as Map<String, dynamic>?;
    if(arguments != null) {
      if(arguments.containsKey('reservation')) {
        isUpdate = true;
        final reservationData = arguments['reservation'] as Map<String, dynamic>;
        print('수정 모드 전달 : $reservationData');
        reserveId = reservationData['id']?.toString();
        shareId = reservationData['shareId']?.toString();
        ownerUid = reservationData['ownerUid']?.toString();

        contactController.text = reservationData['userPNumber'] ?? '';
        startController.text = reservationData['startTime'] ?? '';
        endController.text = reservationData['endTime'] ?? '';
        print('예약 수정 모드');
      }else if(arguments.containsKey('station')) {
        isUpdate = false;
        final reserv = arguments['station'] as Map<String, dynamic>;
        shareId = reserv['id']?.toString();
        ownerUid = reserv['ownerUid']?.toString();
        print('예약 모드');
      }
    }
    // _resetState(); 입력 창 초기화

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
    });
    try {
      http.Response response;
      String successMessage;
      if(isUpdate) {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}/${reserveId}');
        print('수정 url : $url');
        response = await http.put(url, headers: headers, body: body);
        successMessage = '수정이 완료되었습니다.';
        if (Get.isRegistered<ReservUserController>()) {
          Get.find<ReservUserController>().loadreservCharge();
        }
      } else {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}');
        print('예약 url $url');
        response = await http.post(url, headers: headers, body: body);
        successMessage = '예약이 완료되었습니다.';
        // if (Get.isRegistered<ReservUserController>()) {
        //   Get.find<ReservUserController>().loadreservCharge();
        // }
      }
      if (response.statusCode == 200) {
        Get.snackbar('', successMessage);
        _resetState();
      }else if(_isOverlapError(response)){
        Get.snackbar('', '이미 예약된 시간입니다.');
        _resetState();
      }
      else {
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
bool _isOverlapError(http.Response resp) {
  try {
    final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    final text = '${data['error'] ?? ''} ${data['status'] ?? ''} ';
    return text.contains('이미 예약된 시간') || text.contains('겹칩니다');
  } catch (_) {
    final raw = utf8.decode(resp.bodyBytes);
    return raw.contains('이미 예약된 시간') || raw.contains('겹칩니다');
  }
}