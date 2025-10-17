import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:evfinder_front/Controller/reserv_user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'charge_detail_controller.dart';

class ReservController extends GetxController {
  final contactController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  late final AppLinks appLinks;
  RxBool isLoading = false.obs;
  Map<String, dynamic>? reservdata;

  bool isUpdate = false;

  String? uid;
  String? shareId;
  String? ownerUid;
  String? userName;
  String? reserveId;

  @override
  void onInit() {
    super.onInit();
    appLinks = AppLinks();
    _loadUidandUsername();
    handleInitialLink();
    startPayLinkListener();
  }

  @override
  void onClose() {
    stopPayLinkListener();
    super.onClose();
  }

  void _resetState() {
    isUpdate = false;
    reserveId = null;
    shareId = null;
    ownerUid = null;

    contactController.clear();
    startController.clear();
    endController.clear();
  }

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // 날짜 선택 메서드
  void selectStartDate(DateTime date) {
    selectedStartDate = date;
    update(); // GetX 상태 업데이트
  }

  void selectEndDate(DateTime date) {
    selectedEndDate = date;
    update();
  }

  DateTime? parseDateTime(String dateTimeString) {
    try {
      // "2024-01-15 오후 2:00" 형태의 문자열을 파싱
      final parts = dateTimeString.split(' ');
      if (parts.length >= 3) {
        final datePart = parts[0]; // "2024-01-15"
        final periodPart = parts[1]; // "오후" 또는 "오전"
        final timePart = parts[2]; // "2:00"

        final date = DateTime.parse(datePart);
        final timeParts = timePart.split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // 오후인 경우 12시간 추가 (12시는 제외)
        if (periodPart == '오후' && hour != 12) {
          hour += 12;
        } else if (periodPart == '오전' && hour == 12) {
          hour = 0;
        }

        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    } catch (e) {
      print('DateTime 파싱 오류: $e');
    }
    return null;
  }

  // 시간 비교 및 검증 메서드도 추가
  bool validateEndTime() {
    final startText = startController.text.trim();
    final endText = endController.text.trim();

    if (startText.isNotEmpty && endText.isNotEmpty) {
      final startDt = parseDateTime(startText);
      final endDt = parseDateTime(endText);

      if (startDt != null && endDt != null && endDt.isBefore(startDt)) {
        Get.snackbar('시간 오류', '종료 시간이 시작 시간보다 빠를 수 없습니다.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
        // 종료 시간만 초기화하고 update() 호출하지 않음
        endController.clear();
        selectedEndDate = null;
        // update(); // 이 줄을 제거
        return false;
      }
    }
    return true;
  }

  void selectMode() async {
    print('select Mode 실행');
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      if (arguments.containsKey('reservation')) {
        isUpdate = true;
        final reservationData = arguments['reservation'] as Map<String, dynamic>;
        print('수정 모드 전달 : $reservationData');
        reserveId = reservationData['id']?.toString();
        shareId = reservationData['shareId']?.toString();
        ownerUid = reservationData['ownerUid']?.toString();

        contactController.text = reservationData['userPNumber'] ?? '';
        startController.text = reservationData['startTime'] ?? '';
        endController.text = reservationData['endTime'] ?? '';
        print('예약 수정 모드');
      } else if (arguments.containsKey('station')) {
        isUpdate = false;
        reservdata = arguments['station'] as Map<String, dynamic>;
        shareId = reservdata?['id']?.toString();
        ownerUid = reservdata?['ownerUid']?.toString();
        print('예약 모드');
      }
    }
    // _resetState(); 입력 창 초기화

  }



  Future<void> _loadUidandUsername() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    userName = prefs.getString('name');
  }

  Future<void> reserv(BuildContext context) async {
    final userPNumber = contactController.text;
    final startTimeText = startController.text;
    final endTimeText = endController.text;

    final headers = {'Content-Type': 'application/json'};

    if (userPNumber.isEmpty || startTimeText.isEmpty || endTimeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('연락처와 시간을 모두 입력해주세요.')));
      return;
    }

    // parseDateTime으로 파싱 후 UTC ISO 형식으로 변환
    final startDateTime = parseDateTime(startTimeText);
    final endDateTime = parseDateTime(endTimeText);


    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('시간 형식이 올바르지 않습니다.')));
      return;
    }

    final startUtc = startDateTime.toUtc().toIso8601String();
    final endUtc = endDateTime.toUtc().toIso8601String();

    final Duration diff = endDateTime.toUtc().difference(startDateTime.toUtc());
    final int useHours = diff.inHours;
    final int price = (reservdata?['pricePerHour'] as num?)?.toInt() ?? 0;
    final int total = price * useHours;

    final body = jsonEncode({'shareId': shareId, "ownerUid": ownerUid, 'userName': userName, 'userPNumber': userPNumber, 'startTime': startUtc, 'endTime': endUtc});

    try {
      http.Response response;
      String successMessage;
      if (isUpdate) {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}/${reserveId}');
        print('수정 url : $url');
        response = await http.put(url, headers: headers, body: body);
        successMessage = '수정이 완료되었습니다.';
        if (Get.isRegistered<ReservUserController>()) {
          Get.find<ReservUserController>().loadreservCharge();
        }
      } else {
        final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/${uid}');
        print('예약 url $url');
        response = await http.post(url, headers: headers, body: body);
        successMessage = '예약이 완료되었습니다.';
        // Get.toNamed("/main");
        // if (Get.isRegistered<ReservUserController>()) {
        //   Get.find<ReservUserController>().loadreservCharge();
        // }
      }

      if (response.statusCode == 200) {
        Get.snackbar('', successMessage);
        if(!isUpdate) {
          Map<String, dynamic> respJson = {};
          try {
            respJson = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          } catch (_) {}
          final created = (respJson['data'] is Map)
              ? (respJson['data'] as Map<String, dynamic>)
              : respJson;

          final createdReservationId = created['reserveId'].toString();

          if(createdReservationId.isEmpty) {
            Get.snackbar('', '예약 id를 찾을 수 없습니다.');
          }
          kakaopay(reserveId: createdReservationId, amount: total);
        }
        _resetState();
      } else if (_isOverlapError(response)) {
        Get.snackbar('', '이미 예약된 시간입니다.');
        _resetState();
      } else {
        final msg = response.body.isNotEmpty ? response.body : '요청 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패(${response.statusCode}) : $msg')));
      }
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
  }

  Future<void> deleteReserv(String? reserveId) async {
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
        print('결제 안 해서 예약 취소 함');
        Get.snackbar('', '결제 시간이 지나 예약이 취소되었습니다.');
        // loadreservCharge();
      }
    } finally {
      isLoading.value = false;
    }
  }

  //결제
  String? lastTid;
  String? lastOrderId;
  String? paymentReserveId;

  StreamSubscription<Uri>? linkSub;

  Future <void> kakaopay({required String reserveId, required int amount}) async {
    try {
      isLoading.value = true;
      paymentReserveId = reserveId;
      final response = await http.post(
        Uri.parse('${ApiConstants.payApiBaseUrl}/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "uid": uid,
          "itemName": reservdata?['stationName'],
          "amount": amount,
          "reserveId": reserveId //id는 예약 응답
        }),
      );
      print("kakao 서버 응답 코드: ${response.statusCode}");
      print("kakao 서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode != 200) {
        Get.snackbar('결제 요청 실패', '서버 응답 코드: ${response.statusCode}');
        await deleteReserv(reserveId);
        //예약 취소 추가해야함
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
      Future.delayed(const Duration(seconds: 60), () {
        if (paymentReserveId != null) {
          deleteReserv(paymentReserveId!);
          paymentReserveId = null;
        }
      });
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
    //   deleteReserv(paymentReserveId);
    // } else if (status == 'fail') {
    //   Get.snackbar('', '결제가 실패했어요.');
    //   deleteReserv(paymentReserveId);
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
          "uid": uid,
          "orderId": lastOrderId,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('결제 완료', '충전권 결제가 완료되었습니다.');
        paymentReserveId = null;
        Get.toNamed("/main");
      }
    } catch (e) {
      Get.snackbar('승인 오류', e.toString());
    } finally {
      isLoading.value = false;
    }

  }
bool _isOverlapError(http.Response resp) {
  try {
    final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    final text = '${data['error'] ?? ''} ${data['status'] ?? ''} ';
    return text.contains('이미 예약된 시간') || text.contains('겹칩니다');
  } catch (_) {
    final raw = utf8.decode(resp.bodyBytes);
    return raw.contains('이미 예약된 시간') || raw.contains('겹칩니다');
  }
}}