import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Constants/api_constants.dart';

class ReservUserController extends GetxController {
  RxBool isLoading = false.obs;
  final reserveStation = <Map<String, dynamic>>[].obs;
  final userReview = <Map<String, dynamic>>[].obs;
  final userPay = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;
  final ratings = <String, double>{}.obs;
  late final AppLinks appLinks;

  @override
  void onInit() {
    super.onInit();
    appLinks = AppLinks();
    loadUidAndreserv();
    handleInitialLink();
    startPayLinkListener();
  }

  @override
  void onClose() {
    stopPayLinkListener();
    super.onClose();
  }

  Future<void> loadUidAndreserv() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await loadreservCharge();
    Review();
    payStatus();
  }

  Future<void> loadreservCharge() async {
    isLoading.value = true;

    try {
      final rawReservCharge = await fetchReservCharge(uid.value);
      reserveStation.assignAll(
        rawReservCharge.map(
              (e) =>
          {
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
            "rating": 0.0,
            "ratingCount": 0,
            "pricePerHour": e['pricePerHour'] ?? 0.0,
          },
        ),
      );
      print('reserveStation : $reserveStation');
    } finally {
      isLoading.value = false;
    }
    _fillRatingsForAll();
  }

  final Map<String, Map<String, dynamic>> _ratingCache = {};

  Future<void> _fillRatingsForAll() async {
    final seen = <String>{};

    for (var i = 0; i < reserveStation.length; i++) {
      final shareId = reserveStation[i]['shareId']?.toString() ?? '';
      if (shareId.isEmpty || shareId == '알 수 없음') continue;
      if (seen.contains(shareId)) {
        final cached = _ratingCache[shareId];
        if (cached != null) {
          final updated = Map<String, dynamic>.from(reserveStation[i]);
          updated['rating'] = (cached['averageRating'] as num).toDouble();
          updated['ratingCount'] = (cached['count'] as num).toInt();
          reserveStation[i] = updated;
        }
        continue;
      }

      try {
        final stats = _ratingCache[shareId] ?? await fetchReviewStats(shareId);
        _ratingCache[shareId] = stats;

        final avg = (stats['averageRating'] is num)
            ? (stats['averageRating'] as num).toDouble()
            : double.tryParse('${stats['averageRating']}') ?? 0.0;

        final cnt = (stats['count'] is num)
            ? (stats['count'] as num).toInt()
            : int.tryParse('${stats['count']}') ?? 0;

        final updated = Map<String, dynamic>.from(reserveStation[i]);
        updated['rating'] = avg;
        updated['ratingCount'] = cnt;
        reserveStation[i] = updated;

        seen.add(shareId);
      } catch (_) {}
    }
  }

  static Future<Map<String, dynamic>> fetchReviewStats(String stationId) async {
    final url = Uri.parse('${ApiConstants.reviewBaseUrl}/stats/$stationId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      return json;
    } else {
      throw Exception('Failed to fetch review stats');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReservCharge(
      String uid) async {
    final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}');
    final response = await http.get(url);

    print("서버 응답 코드: ${response.statusCode}");
    print("서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch hostCharge');
    }
  }

  Future<void> deleteReserv(String reserveId) async {
    if (reserveId == null || reserveId.isEmpty || reserveId == '알 수 없음') {
      Get.snackbar('', '예약 정보가 올바르지 않습니다.');
      return;
    }

    try {
      isLoading.value = true;
      final url = Uri.parse(
          '${ApiConstants.reservApiBaseUrl}/${uid}/${reserveId}');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Get.snackbar('', '예약 취소가 완료되었습니다.');
        loadreservCharge();
      } else {
        Get.snackbar('', '예약 취소를 실패하었습니다.');
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

  Future <void> Review() async {
    try {
      isLoading.value = true;
      final review = await fetchReview(uid.value);
      userReview.assignAll(
        review.map(
              (e) =>
          {
            // "reviewId": e['reviewId']?.toString() ?? '알 수 없음',
            "id": e['id']?.toString() ?? '알 수 없음', //shareId
            // "name": e['name']?.toString() ?? '알 수 없음',
            // "uid": e['uid']?.toString() ?? '알 수 없음',
            // "userName": e['userName']?.toString() ?? '알 수 없음',
            // "rating": e['rating'] ?? 0,
            // "content": e['content']?.toString() ?? '알 수 없음',
            // "createdAt":  e['createdAt']?.toString() ?? '알 수 없음',
            // "updatedAt":  e['updatedAt']?.toString() ?? '알 수 없음',
          },
        ),
      );
      print('userReview : $userReview');
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReview(String uid) async {
    final url = Uri.parse('${ApiConstants.reviewBaseUrl}/list/user/${uid}');
    final response = await http.get(url);

    print('내가 쓴 리뷰 url : $url');
    print('내가 쓴 리뷰 코드: ${response.statusCode}');
    print('내가 쓴 리뷰 내용: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch userReview');
    }
  }

  Future <void> payStatus() async {
    try {
      isLoading.value = true;
      final review = await fetchpay(uid.value);
      userPay.assignAll(
        review.map(
              (e) =>
          {
            "itemName": e['itemName']?.toString() ?? '알 수 없음',
            "amount": e['amount'] ?? 0.0,
            "reserveId": e['reserveId']?.toString() ?? '알 수 없음',
            "orderId": e['orderId']?.toString() ?? '알 수 없음',
            "paymentId": e['paymentId']?.toString() ?? '알 수 없음',
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
      throw Exception('Failed to fetch userPay');
    }
  }

  late String lastTid;
  late String lastOrderId;

  StreamSubscription<Uri>? linkSub;

  Future <void> kakaopay({required Map<String, dynamic> reservation}) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('${ApiConstants.payApiBaseUrl}/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "uid": uid.value,
          "itemName": reservation['stationName'],
          "amount": reservation['pricePerHour'],
          "reserveId": reservation['id']
        }),
      );
      print("kakao 서버 응답 코드: ${response.statusCode}");
      print("kakao 서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode != 200) {
        Get.snackbar('결제 요청 실패', '서버 응답 코드: ${response.statusCode}');
        return;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      lastTid = data['tid'];
      lastOrderId = data['orderId'];

      final String webUrl = data['next_redirect_mobile_url'];
      final String? scheme = Platform.isAndroid
          ? data['android_app_scheme']
          : data['ios_app_scheme'];

      if (scheme != null && scheme.isNotEmpty) {
        final appUri = Uri.parse(scheme);
        if (await canLaunchUrl(appUri)) {
          if (await launchUrl(appUri, mode: LaunchMode.externalApplication))
            return;
        }
      }

      await launchUrl(
        Uri.parse(webUrl),
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startPayLinkListener() {
    linkSub?.cancel();
    linkSub = appLinks.uriLinkStream.listen(
            (uri) => handlePayUri(uri),
        onError: (e) =>Get.snackbar('링크 오류', e.toString()),
    );
  }

  void stopPayLinkListener() {
    linkSub?.cancel();
    linkSub = null;
  }

  Future<void> handleInitialLink() async {
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        handlePayUri(initial);
      }
    } catch (e) {
      Get.snackbar('초기 링크 오류', e.toString());
    }
  }

  void handlePayUri(Uri uri) {
    final ok = uri.scheme == 'evfinder' && uri.host == 'kakaopay';
    if (!ok) return;

    final status = uri.queryParameters['status'];
    final orderId = uri.queryParameters['orderId'];
    final pgToken = uri.queryParameters['pg_token'];

    if (status == 'success' && pgToken != null && orderId != null) {
      approvePayment(pgToken: pgToken, orderId: orderId);
    }
    // else if (status == 'cancel') {
    //   Get.snackbar('', '사용자가 결제를 취소했어요.');
    // } else if (status == 'fail') {
    //   Get.snackbar('', '결제가 실패했어요.');
    // }
  }

  Future<void> approvePayment(
      {required String pgToken, required String orderId}) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${ApiConstants.payApiBaseUrl}/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "pg_token": pgToken,
          "tid": lastTid,
          "uid": uid.value,
          "orderId": lastOrderId,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('결제 완료', '충전권 결제가 완료되었습니다.');
      } else {
        Get.snackbar('승인 실패', '서버 응답 코드: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('승인 오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelPayment({required String tid}) async {
    try {
      final url = Uri.parse('${ApiConstants.payApiBaseUrl}/cancel?uid=${uid.value}&tid=${tid}');
      final response = await http.get(url);
      print("결제 취소 코드: ${response.statusCode}");
      print("결제 취소 내용: ${utf8.decode(response.bodyBytes)}");
      if (response.statusCode == 200) {
        payStatus;
        Get.snackbar('', '결제가 취소되었습니다.');
      } else{
        throw Exception('Failed to fetch customer');
      }
    } finally {
      isLoading.value = false;
    }
  }
}