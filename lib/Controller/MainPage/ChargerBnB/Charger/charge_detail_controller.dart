import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Charger/bnb_station_controller.dart';
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

  // 예약된 시간대 관련 추가
  RxList<String> reservedTimeSlots = <String>[].obs;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUid();

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

  // 기존 코드들...
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

  // 기존 fetchReservedDates 메서드를 수정하여 시간대 저장 기능 추가
  Future<void> fetchReservedTimeSlots(String shareId) async {
    final headers = {'Content-Type': 'application/json'};
    try {
      http.Response response;
      final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/share/$shareId');
      response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print("fetchReservedTimeSlots success");
        final List<dynamic> data = json.decode(response.body);

        List<String> allReservedSlots = [];

        for (var reservation in data) {
          DateTime startDateTime = DateTime.parse(reservation['startTime']);
          DateTime endDateTime = DateTime.parse(reservation['endTime']);

          // 시작 시간부터 종료 시간까지 1시간 단위로 생성
          DateTime currentTime = startDateTime;
          while (currentTime.isBefore(endDateTime)) {
            // "yyyy-MM-dd HH:mm" 형식으로 저장 (시간 비교용)
            String timeSlot = DateFormat('yyyy-MM-dd HH:mm').format(currentTime.toLocal());
            allReservedSlots.add(timeSlot);
            currentTime = currentTime.add(Duration(hours: 1));
          }
        }

        // 중복 제거 및 정렬
        allReservedSlots = allReservedSlots.toSet().toList();
        allReservedSlots.sort();

        reservedTimeSlots.value = allReservedSlots;
        print("예약된 시간대들: $reservedTimeSlots");
      } else {
        print('fetchReservedTimeSlots Status Code: ${response.statusCode}');
        print('fetchReservedTimeSlots Response Body: ${response.body}');
        reservedTimeSlots.clear();
      }
    } catch (e) {
      print("fetchReservedTimeSlots error: $e");
      reservedTimeSlots.clear();
    }
  }

  // 기존 fetchReservedDates는 그대로 유지 (다른 곳에서 사용할 수 있으므로)
  // Future<List<String>> fetchReservedDates(String shareId) async {
  //   final headers = {'Content-Type': 'application/json'};
  //   try {
  //     http.Response response;
  //     final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/share/$shareId');
  //     response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       print("fetchReservedDates success");
  //       final List<dynamic> data = json.decode(response.body);
  //
  //       List<String> allReservedSlots = [];
  //
  //       for (var reservation in data) {
  //         DateTime startDateTime = DateTime.parse(reservation['startTime']);
  //         DateTime endDateTime = DateTime.parse(reservation['endTime']);
  //
  //         // 시작 시간부터 종료 시간까지 1시간 단위로 생성
  //         DateTime currentTime = startDateTime;
  //         while (currentTime.isBefore(endDateTime)) {
  //           String timeSlot = DateFormat('M월 d일 H시').format(currentTime.toLocal());
  //           allReservedSlots.add(timeSlot);
  //           currentTime = currentTime.add(Duration(hours: 1));
  //         }
  //       }
  //
  //       // 중복 제거 및 정렬
  //       allReservedSlots = allReservedSlots.toSet().toList();
  //       allReservedSlots.sort();
  //
  //       print("예약된 시간대들: $allReservedSlots");
  //       return allReservedSlots;
  //     }
  //
  //     print('fetchReservedDates Status Code: ${response.statusCode}');
  //     print('fetchReservedDates Response Body: ${response.body}');
  //     return [];
  //   } catch (e) {
  //     print("fetchReservedDates error: $e");
  //     return [];
  //   }
  // }

  // 특정 날짜의 특정 시간이 예약되어 있는지 확인
  bool isTimeSlotReserved(DateTime date, String period, String time) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);

    // 시간 형식 변환 (12시간 -> 24시간)
    int hour = int.parse(time.split(':')[0]);
    if (period == '오후' && hour != 12) {
      hour += 12;
    } else if (period == '오전' && hour == 12) {
      hour = 0;
    }

    String timeSlot = '$dateStr ${hour.toString().padLeft(2, '0')}:00';
    return reservedTimeSlots.contains(timeSlot);
  }

  // 특정 날짜에 예약된 시간이 있는지 확인
  bool hasReservationsOnDate(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return reservedTimeSlots.any((slot) => slot.startsWith(dateStr));
  }

  // 특정 날짜가 완전히 예약되어 있는지 확인 (모든 시간대가 예약된 경우)
  bool isDayFullyBooked(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    int reservedCount = reservedTimeSlots.where((slot) => slot.startsWith(dateStr)).length;
    return reservedCount >= 24; // 24시간 모두 예약된 경우
  }

  // 오전/오후 시간을 24시간 형식으로 변환
  int _convertTo24Hour(String period, String time) {
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);

    if (period == '오전') {
      if (hour == 12) return 0; // 오전 12시 = 0시
      return hour;
    } else {
      // 오후
      if (hour == 12) return 12; // 오후 12시 = 12시
      return hour + 12;
    }
  }

  // 예약된 시간대 데이터 로드 (shareId를 매개변수로 받음)
  Future<void> loadReservedTimeSlots(String shareId) async {
    isLoading.value = true;
    try {
      await fetchReservedTimeSlots(shareId);
    } finally {
      isLoading.value = false;
    }
  }

  // 기존 코드들 계속...
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

  // 나머지 기존 메서드들은 그대로 유지...
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
        final Map<String, dynamic> data = json.decode(response.body);
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
      final response = await http.post(url, headers: headers, body: jsonEncode(dates));

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
      final response = await http.delete(url, headers: headers, body: jsonEncode(dates));

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
        // 예약된 시간대도 함께 로드
        await fetchReservedTimeSlots(shareId);
      } finally {
        isLoading.value = false;
      }
    } else {
      reserveAvailableDate.value = null;
      reservedTimeSlots.clear();
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

  // 기존 날짜 선택 관련 메서드들...
  void selectStartDate(DateTime date) {
    selectedStartDate.value = date;
    print('선택된 시작 날짜: $date');
  }

  void selectEndDate(DateTime date) {
    selectedEndDate.value = date;
    print('선택된 시작 날짜: $date');
  }

  void clearSelectedDates() {
    selectedStartDate.value = null;
  }

  void selectDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;

    print('선택된 범위: ${start.toString().split(' ')[0]} ~ ${end.toString().split(' ')[0]}');

    int dayCount = end.difference(start).inDays + 1;
    print('선택된 일수: $dayCount일');
  }

  List<String> getSelectedDateRange() {
    if (selectedStartDate.value == null) {
      return [];
    }

    List<String> dates = [];
    DateTime current = selectedStartDate.value!;
    DateTime endDate = selectedEndDate.value ?? selectedStartDate.value!;

    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      String dateString =
          '${current.year.toString().padLeft(4, '0')}-'
          '${current.month.toString().padLeft(2, '0')}-'
          '${current.day.toString().padLeft(2, '0')}';
      dates.add(dateString);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  void clearDateRange() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
  }
}
