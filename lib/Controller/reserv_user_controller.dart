import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';

class ReservUserController extends GetxController {
  RxBool isLoading = false.obs;
  final reserveStation = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUidAndreserv();
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
            "id": e['id']?.toString() ?? '알 수 없음', //reserveid
            "shareId": e['shareId']?.toString() ?? '알 수 없음',
            "address": e['address']?.toString() ?? '알 수 없음',
            "ownerUid": e['ownerUid']?.toString() ?? '알 수 없음',
            "userName": e['userName']?.toString() ?? '알 수 없음',
            "stationName": e['stationName']?.toString() ?? '알 수 없음',
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

  Future <void> deleteReserv(String reserveId) async{
    if (reserveId == null || reserveId.isEmpty || reserveId == '알 수 없음') {
      Get.snackbar('', '예약 정보가 올바르지 않습니다.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}/${reserveId}');
      final response = await http.delete(url);

      if(response.statusCode == 200) {
        Get.snackbar('', '예약 취소가 완료되었습니다.', snackPosition: SnackPosition.BOTTOM);
        loadreservCharge();
      } else {
        Get.snackbar('', '예약 취소를 실패하었습니다.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void confirmDeleteReverse(String reserveId) {
    Get.defaultDialog(
      title: '예약 취소',
      middleText: '정말로 취소하시겠어요? 이 작업은 되돌릴 수 없습니다.',
      textCancel: '돌아가기',
      textConfirm: '예약 취소',
      confirmTextColor: const Color(0xFF0F172A),
      onConfirm: () {
        Get.back();
        deleteReserv(reserveId);
      },
    );
  }
}