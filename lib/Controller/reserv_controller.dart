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

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // 날짜 선택 메서드
  void selectStartDate(DateTime date) {
    selectedStartDate = date;
    update(); // GetX 상태 업데이트
  }

  void selectEndDate(DateTime date) {
    selectedEndDate = date;
    update();
  }

  DateTime? parseDateTime(String dateTimeString) {
    try {
      // "2024-01-15 오후 2:00" 형태의 문자열을 파싱
      final parts = dateTimeString.split(' ');
      if (parts.length >= 3) {
        final datePart = parts[0]; // "2024-01-15"
        final periodPart = parts[1]; // "오후" 또는 "오전"
        final timePart = parts[2]; // "2:00"

        final date = DateTime.parse(datePart);
        final timeParts = timePart.split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // 오후인 경우 12시간 추가 (12시는 제외)
        if (periodPart == '오후' && hour != 12) {
          hour += 12;
        } else if (periodPart == '오전' && hour == 12) {
          hour = 0;
        }

        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    } catch (e) {
      print('DateTime 파싱 오류: $e');
    }
    return null;
  }

  // 시간 비교 및 검증 메서드도 추가
  bool validateEndTime() {
    final startText = startController.text.trim();
    final endText = endController.text.trim();

    if (startText.isNotEmpty && endText.isNotEmpty) {
      final startDt = parseDateTime(startText);
      final endDt = parseDateTime(endText);

      if (startDt != null && endDt != null && endDt.isBefore(startDt)) {
        Get.snackbar('시간 오류', '종료 시간이 시작 시간보다 빠를 수 없습니다.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
        // 종료 시간만 초기화하고 update() 호출하지 않음
        endController.clear();
        selectedEndDate = null;
        // update(); // 이 줄을 제거
        return false;
      }
    }
    return true;
  }

  void selectMode() {
    print('select Mode 실행');
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      if (arguments.containsKey('reservation')) {
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
      } else if (arguments.containsKey('station')) {
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

  Future<void> reserv(BuildContext context) async {
    final userPNumber = contactController.text;
    final startTimeText = startController.text;
    final endTimeText = endController.text;

    final headers = {'Content-Type': 'application/json'};

    if (userPNumber.isEmpty || startTimeText.isEmpty || endTimeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('연락처와 시간을 모두 입력해주세요.')));
      return;
    }

    // parseDateTime으로 파싱 후 UTC ISO 형식으로 변환
    final startDateTime = parseDateTime(startTimeText);
    final endDateTime = parseDateTime(endTimeText);

    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('시간 형식이 올바르지 않습니다.')));
      return;
    }

    final startUtc = startDateTime.toUtc().toIso8601String();
    final endUtc = endDateTime.toUtc().toIso8601String();

    final body = jsonEncode({'shareId': shareId, "ownerUid": ownerUid, 'userName': userName, 'userPNumber': userPNumber, 'startTime': startUtc, 'endTime': endUtc});

    try {
      http.Response response;
      String successMessage;
      if (isUpdate) {
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
        Get.toNamed("/main");
      }

      if (response.statusCode == 200) {
        Get.snackbar('', successMessage);
        _resetState();
      } else if (_isOverlapError(response)) {
        Get.snackbar('', '이미 예약된 시간입니다.');
        _resetState();
      } else {
        final msg = response.body.isNotEmpty ? response.body : '요청 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패(${response.statusCode}) : $msg')));
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
