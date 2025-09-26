import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChargeDetailController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUid();
  }

  Future<String?> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<void> statChange(String shareId, String status) async {

    isLoading.value = true;
    try {

      final String? uid = await _loadUid();
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/$uid/$shareId/status?status=$status');
      final response = await http.patch(url);


      print("상태 url: $url");
      print("전달 Uid: $uid");
      print('상태 변경 코드: ${response.statusCode}');
      print('상태 변경 내용: ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar('', '상태 변경 완료');
      } else{
        throw Exception('Failed to update status. Server responded with ${response.statusCode}');
      }
    } catch (e) { // catch 블록을 추가하여 예외를 처리합니다.
      print("Error in statChange: $e");
      Get.snackbar("오류", "상태 변경 중 문제가 발생했습니다.");
    }
    finally {
      isLoading.value = false;
    }
    }
  }
