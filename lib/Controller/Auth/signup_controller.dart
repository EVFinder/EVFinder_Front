import 'dart:convert';
import 'package:evfinder_front/Util/Route/app_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../Constants/api_constants.dart';
import 'package:http/http.dart' as http;

class SignupController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneNumController.dispose();
    super.onClose();
  }

  Future<void> handleSignup(BuildContext context) async {
    // 입력 검증
    if (!_validateInput(context)) {
      return;
    }

    isLoading.value = true;

    try {
      await signup(context);
    } finally {
      isLoading.value = false;
    }
  }

  bool _isPasswordSecure(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _validateInput(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final name = nameController.text.trim();
    final phoneNum = phoneNumController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('오류', '이메일을 입력하세요.');
      return false;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('오류', '올바른 이메일 형식을 입력하세요.');
      return false;
    }

    if (name.isEmpty) {
      Get.snackbar('오류', '이름을 입력하세요.');
      return false;
    }

    if (phoneNum.isEmpty) {
      Get.snackbar('오류', '전화번호를 입력하세요.');
      return false;
    }

    if (password.length < 6) {
      Get.snackbar('오류', '비밀번호는 최소 6자 이상이어야 합니다.');
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar('오류', '비밀번호가 일치하지 않습니다.');
      return false;
    }

    if (!_isPasswordSecure(password)) {
      Get.snackbar('오류', '비밀번호는 8자 이상, 영문/숫자/특수문자를 포함해야 합니다.');
      return false;
    }

    return true;
  }

  Future<void> signup(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final phoneNum = phoneNumController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authApiBaseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'userName': name, 'phone': phoneNum}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        Get.dialog(
          AlertDialog(
            title: const Text('성공'),
            content: const Text('회원가입이 완료되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // 다이얼로그 닫기
                  Get.offAndToNamed(AppRoute.login);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('실패'),
            content: const Text('회원가입에 실패하였습니다.'),
            actions: [TextButton(onPressed: () => Get.back(), child: const Text('확인'))],
          ),
        );
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('오류'),
          content: Text('회원가입 실패: ${e.toString()}'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('확인'))],
        ),
      );
    }
  }
}
