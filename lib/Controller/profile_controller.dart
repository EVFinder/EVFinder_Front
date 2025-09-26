import 'dart:convert';
import 'package:evfinder_front/View/login_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Constants/api_constants.dart';
import '../View/change_password.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  final newPasswordController = TextEditingController();
  final reserveStation = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUidAndreserv();
  }

  // 화면이 다시 보일 때마다 데이터 새로고침
  @override
  void onReady() {
    super.onReady();
    loadreservCharge(); // 추가: 화면이 준비될 때마다 예약 데이터 다시 로드
  }

  Future<void> loadUidAndreserv() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await loadreservCharge();
  }

  Future <void> loadreservCharge()async {
    isLoading.value = true;

    try {
      final rawReservCharge = await fetchReservCharge(uid.value);
      reserveStation.assignAll(
        rawReservCharge.map(
              (e) => {
            "shareId": e['shareId']?.toString() ?? '알 수 없음',
            "ownerUid": e['ownerUid']?.toString() ?? '알 수 없음',
            "userName": e['userName']?.toString() ?? '알 수 없음',
            "userPNumber": e['userPNumber']?.toString() ?? '알 수 없음',
            "startTime": e['startTime']?.toString() ?? '알 수 없음',
            "endTime": e['endTime']?.toString() ?? '알 수 없음',
            "createdAt": e['createdAt']?.toString() ?? '알 수 없음',
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReservCharge(String uid) async {
    final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}');
    final response = await http.get(url);

    print("서버 응답 코드: ${response.statusCode}");
    print("서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else{
      throw Exception('Failed to fetch hostCharge');
    }
  }

  void handleChangePassword() {
    Get.to(() => const ChangePasswordView());
  }

  //로그아웃
  Future<void> handleLogout() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      await FirebaseAuth.instance.signOut();
      await prefs.clear();
      Get.offAll(() => const LoginView());
      Get.snackbar('', '로그아웃 되었습니다.', snackPosition: SnackPosition.BOTTOM);
    } catch(e) {
      Get.snackbar('', '로그아웃 중 문제 발생하였습니다: $e', snackPosition: SnackPosition.BOTTOM);
    } finally{
      isLoading.value = false;
    }
  }

//비밀번호 변경
  Future<void> changePassword(String newPassword) async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        Get.snackbar('', 'ID 토큰을 가져올 수 없습니다.',snackPosition: SnackPosition.BOTTOM);
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

      if(response.statusCode != 200) {
        Get.snackbar('', '서버 오류 (${response.statusCode})',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded['success']) {
        Get.snackbar('', '비밀번호 변경 완료',
            snackPosition: SnackPosition.BOTTOM);
        Get.back();
      } else {
        Get.snackbar('', '실패: ${decoded['message']}', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('', '에러 발생: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt'); // 저장된 JWT 토큰

      if (jwt == null) {
        Get.snackbar('', '로그인이 필요합니다.', snackPosition: SnackPosition.BOTTOM);
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
        Get.offAll(() => const LoginView());
        Get.snackbar('', '회원탈퇴가 완료되었습니다.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('', '실패: ${decoded['message']}', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('', '오류 발생: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  void confirmDeleteAccount() {
    Get.defaultDialog(
      title: '회원 탈퇴',
      middleText: '정말로 탈퇴하시겠어요? 이 작업은 되돌릴 수 없습니다.',
      textCancel: '취소',
      textConfirm: '탈퇴',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        deleteAccount();
      },
    );
  }
}
