import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../Constants/api_constants.dart';

class PaymentHistoryController extends GetxController {
  RxBool isLoading = false.obs;
  final payHistory = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUid();
  }

  Future<void> loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await paymentHistory();
  }

  Future <void> paymentHistory() async {
    try {
      isLoading.value = true;
      final review = await fetchpay(uid.value);
      payHistory.assignAll(
        review.map(
              (e) =>
          {
            "createdAt":  e['createdAt']?.toString() ?? '알 수 없음',
            "itemName": e['itemName']?.toString() ?? '알 수 없음',
            "amount": e['amount'] ?? 0.0,
            "reserveId":  e['reserveId']?.toString() ?? '알 수 없음',
            "orderId":  e['orderId']?.toString() ?? '알 수 없음',
            "paymentId":  e['paymentId']?.toString() ?? '알 수 없음', //tid 결제 취소 시 사용
            "cancelledAt": e['cancelledAt']?.toString() ?? '알 수 없음',
            "approvedAt":  e['approvedAt']?.toString() ?? '알 수 없음',
            "status": e['status']?.toString() ?? '알 수 없음',
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchpay(String uid) async {
    final url = Uri.parse('${ApiConstants.payApiBaseUrl}/history?uid=${uid}');
    final response = await http.get(url);

    print('결제 기록 url : $url');
    print('결제 기록: ${response.statusCode}');
    print('결제 기록: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch Payhistory');
    }
  }

  Future<void> cancelPayment({required String tid}) async {
    try {
      final url = Uri.parse('${ApiConstants.payApiBaseUrl}/cancel?uid=${uid.value}&tid=${tid}');
      final response = await http.get(url);
      print("결제 취소 코드: ${response.statusCode}");
      print("결제 취소 내용: ${utf8.decode(response.bodyBytes)}");
      if (response.statusCode == 200) {
        payHistory;
        Get.snackbar('', '결제가 취소되었습니다.');
      } else{
        throw Exception('Failed to fetch customer');
      }
    } finally {
      isLoading.value = false;
    }
  }

}