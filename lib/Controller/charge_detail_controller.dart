import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:evfinder_front/Controller/bnb_station_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChargeDetailController extends GetxController {
  RxBool isLoading = false.obs;
  final bnbReview = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;
  String? stationId;
  BnbStationController bnbStationController = Get.find<BnbStationController>();

  Rx<Map<String, dynamic>?> reserveAvailableDate = Rx<Map<String, dynamic>?>(null);
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  Rx<DateTime> focusedDay = DateTime.now().obs;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUid();

    // loadReview();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final stationData = arguments['station'] as Map<String, dynamic>?;
      if (stationData != null) {
        stationId = stationData['id']?.toString();
        print("리뷰 페이지에 받아 온 정보 : $arguments");
        print("리뷰 페이지에 받아 온 정보 : $stationId");
      }
    }
    if (stationId?.isNotEmpty == true) {
      loadReview();
    }
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
  }

  Future<bool> statChange(String shareId, String status) async {
    isLoading.value = true;
    try {
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/${uid.value}/${shareId}/status?status=${status}');
      final response = await http.patch(url);
      print('Uid $uid');
      print('상태 변경 코드: ${response.statusCode}');
      print('상태 변경 내용: ${response.body}');

      if (response.statusCode == 200) {
        bnbStationController.loadBnbCharge(lat: bnbStationController.lat.value, lon: bnbStationController.lon.value);
        return true;
      } else {
        throw Exception('Failed to update status. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print("Error in statChange: $e");
      Get.snackbar("오류", "상태 변경 중 문제가 발생했습니다.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReview() async {
    isLoading.value = true;
    try {
      final rawreview = await fetchReview();
      bnbReview.assignAll(
        rawreview.map(
          (e) => {
            "reviewId": e['reviewId']?.toString() ?? '알 수 없음',
            "id": e['id']?.toString() ?? '알 수 없음',
            "name": e['name']?.toString() ?? '알 수 없음',
            "uid": e['uid']?.toString() ?? '알 수 없음',
            "userName": e['userName']?.toString() ?? '알 수 없음',
            "rating": e['rating'] ?? 0,
            "content": e['content']?.toString() ?? '알 수 없음',
            "createdAt": e['createdAt']?.toString() ?? '알 수 없음',
            "updatedAt": e['updatedAt']?.toString() ?? '알 수 없음',
          },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchReview() async {
    var urlString = '${ApiConstants.reviewBaseUrl}/list/station/$stationId?orderBy=createdAt&limit=3';

    final url = Uri.parse(urlString);
    print("stationId : $stationId");
    print("리뷰 불러오기 URL: $url");
    final response = await http.get(url);

    print("리뷰 불러오기 응답 코드: ${response.statusCode}");
    print("리뷰 불러오기 내용: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch review');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;

      final url = Uri.parse('${ApiConstants.reviewBaseUrl}/delete/${uid.value}/$reviewId');
      final response = await http.delete(url);

      print("리뷰 삭제 응답 코드: ${response.statusCode}");
      print("리뷰 삭제 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        Get.snackbar('', '리뷰가 삭제되었습니다.');
        loadReview();
      } else {
        Get.snackbar('', '리뷰 삭제를 실패하었습니다.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchDisableDates(String uid, String shareId) async {
    final headers = {'Content-Type': 'application/json'};
    try {
      http.Response response;
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/$uid/$shareId/availability');
      response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print("fetchReserveDate success");
        // JSON 문자열을 Map으로 파싱
        final Map<String, dynamic> data = json.decode(response.body);
        // print(data);
        reserveAvailableDate.value = data;
        return data;
      }
      print('fetchDisableDates Status Code: ${response.statusCode}');
      print('fetchDisableDates Response Body: ${response.body}');
      return null;
    } catch (e) {
      print("fetchReserveDate error: $e");
      return null;
    }
  }

  Future<bool> addDisabledDates(String uid, String shareId, List<String> dates) async {
    final headers = {'Content-Type': 'application/json'};
    try {
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/$uid/$shareId/disabledDates');
      // JSON 배열로 인코딩해서 전송
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(dates), // 이게 핵심!
      );

      if (response.statusCode == 200) {
        print("addDisabledDates success");
        return true;
      }
      print('addDisabledDates Status Code: ${response.statusCode}');
      print('addDisabledDates Response Body: ${response.body}');
      return false;
    } catch (e) {
      print("addDisabledDates error: $e");
      return false;
    }
  }

  Future<bool> deleteDisabledDates(String uid, String shareId, List<String> dates) async {
    final headers = {'Content-Type': 'application/json'};
    try {
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/$uid/$shareId/disabledDates');
      // JSON 배열로 인코딩해서 전송
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode(dates), // 이게 핵심!
      );

      if (response.statusCode == 200) {
        print("deleteDisabledDates success");
        return true;
      }
      print('deleteDisabledDates Status Code: ${response.statusCode}');
      print('deleteDisabledDates Response Body: ${response.body}');
      return false;
    } catch (e) {
      print("deleteDisabledDates error: $e");
      return false;
    }
  }

  Future<void> loadDisabledDates(String? ownerUid, String? shareId) async {
    print("loadDisabledDates 실행");
    if (ownerUid != null && shareId != null) {
      isLoading.value = true;
      try {
        reserveAvailableDate.value = await fetchDisableDates(ownerUid, shareId);
      } finally {
        isLoading.value = false;
      }
    } else {
      reserveAvailableDate.value = null;
    }
    print("예약 불가능 날짜 데이터: ${reserveAvailableDate.value}");
  }

  // 날짜가 비활성화되어야 하는지 확인하는 함수
  bool isDayDisabled(DateTime day) {
    if (reserveAvailableDate.value?["disabledDates"] == null) return false;

    final dayString = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final disabledDates = reserveAvailableDate.value?["disabledDates"] as List<dynamic>?;

    return disabledDates?.contains(dayString) ?? false;
  }

  // 날짜 선택 함수들을 reactive하게 수정
  void selectStartDate(DateTime date) {
    selectedStartDate.value = date;
    print('선택된 시작 날짜: $date');
  }

  void selectEndDate(DateTime date) {
    selectedEndDate.value = date;
    print('선택된 시작 날짜: $date');
  }

  // 선택된 날짜들 초기화
  void clearSelectedDates() {
    selectedStartDate.value = null;
  }

  // 범위 선택
  void selectDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;

    // 선택된 범위 출력 (디버깅용)
    print('선택된 범위: ${start.toString().split(' ')[0]} ~ ${end.toString().split(' ')[0]}');

    // 범위 내 날짜 수 계산
    int dayCount = end.difference(start).inDays + 1;
    print('선택된 일수: $dayCount일');
  }

  // 선택된 범위 내 모든 날짜 가져오기

  List<String> getSelectedDateRange() {
    if (selectedStartDate.value == null) {
      return [];
    }

    List<String> dates = [];
    DateTime current = selectedStartDate.value!;
    DateTime endDate = selectedEndDate.value ?? selectedStartDate.value!; // 종료일이 없으면 시작일과 같게

    // 날짜만 비교 (시간 무시)
    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      // Firebase에 저장하기 좋은 형식 (yyyy-MM-dd)
      String dateString =
          '${current.year.toString().padLeft(4, '0')}-'
          '${current.month.toString().padLeft(2, '0')}-'
          '${current.day.toString().padLeft(2, '0')}';
      dates.add(dateString);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  // 범위 초기화
  void clearDateRange() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
  }
}
