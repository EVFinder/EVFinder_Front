import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final uid = ''.obs;


  @override
  void onInit() {
    super.onInit();
    loadUid();
  }

  Future<void> loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
  }

  Future<void> handleChangePassword(BuildContext context) async {
    final newPassword = passwordController.text.trim();
    final confirmPw = confirmController.text.trim();

    if (newPassword.isEmpty) {
      Get.snackbar('', '비밀번호를 입력하세요', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      if(newPassword == confirmPw) {
        final response = await http.post(
          Uri.parse('${ApiConstants.authApiBaseUrl}/update-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': uid.value,
            'newPassword': newPassword
          }),
        );
        if(response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('변경 완료!')),
          );
          Get.back();
        }else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('변경 실패')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호를 확인해주세요')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
    finally {
      isLoading.value = false;
    }
  }
}