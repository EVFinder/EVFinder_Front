import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservController extends GetxController {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  String? uid;
  String? shareId;
  String? ownerUid;
  @override
  void onInit() {
    super.onInit();
    _loadUid();

    final arguments = Get.arguments as Map<String, dynamic>?;
    if(arguments != null) {
      shareId = arguments['id']?.toString();
      ownerUid = arguments['ownerUid']?.toString();
    }
  }
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    contactController.dispose();
    startController.dispose();
    endController.dispose();
  }
  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid'); // 로그인 시 setString('uid', uid)로 저장했던 값
  }

  Future <void> reserv(BuildContext context) async {
    final userName = nameController.text;
    final userPNumber = contactController.text;
    final startTime = startController.text;
    final endTime = endController.text;
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}'),
          headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shareId': shareId,
          "ownerUid": ownerUid,
          'userName': userName,
          'userPNumber': userPNumber,
          'startTime': startTime,
          'endTime': endTime
        }) //2025-09-27T08:00:00.00Z
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('예약 완료!')),
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