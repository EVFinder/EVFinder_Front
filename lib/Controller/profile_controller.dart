import 'package:evfinder_front/View/login_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  final newPasswordController = TextEditingController();

  void handleChangePassword() {
    Get.to(() => const ChangePasswordView());
  }

  void handleLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Firebase 로그아웃
    await FirebaseAuth.instance.signOut();

    // await prefs.remove('uid');
    // await prefs.remove('userId');
    // await prefs.remove('jwt');
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("로그아웃 되었습니다.")),
    );
  }


  Future<void> changePassword(BuildContext context, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ID 토큰을 가져올 수 없습니다.")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.authApiBaseUrl}/changepw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'newPassword': newPassword,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (decoded['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호 변경 완료")),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("실패: ${decoded['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    }
  }
  Future<void> deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt'); // 저장된 JWT 토큰

      if (jwt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인이 필요합니다.")),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.authApiBaseUrl}/delete'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        await FirebaseAuth.instance.signOut();
        await prefs.clear(); // 로그인 정보 삭제

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원탈퇴가 완료되었습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("실패: ${decoded['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  void handleDeleteAccount() {
    _controller.deleteAccount(context);
  }


}