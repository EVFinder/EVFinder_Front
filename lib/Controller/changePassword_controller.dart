import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ChangePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  final passwordController = TextEditingController();

  Future<void> handleChangePassword() async {
    final newPassword = passwordController.text.trim();

    if (newPassword.isEmpty) {
      Get.snackbar('', '비밀번호를 입력하세요', snackPosition: SnackPosition.BOTTOM);
      return;
    }
  }
}