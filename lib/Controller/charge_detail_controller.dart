import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChargeDetailController extends GetxController {
  RxBool isLoading = false.obs;
  final bnbReview = <Map<String, dynamic>>[].obs;
  final uid = ''.obs;
  String? stationId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUid();
    loadReview();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if(arguments != null) {
      final stationData = arguments['station'] as Map<String, dynamic>?;
      if(stationData != null) {
        stationId = stationData['id']?.toString();
        print("리뷰 페이지에 받아 온 정보 : $arguments");
        print("리뷰 페이지에 받아 온 정보 : $stationId");
      }
    }
    loadReview();
  }

  Future<String?> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
  }

  Future<void> statChange(String shareId, String status) async {

    isLoading.value = true;
    try {

      final String? uid = await _loadUid();
      final url = Uri.parse('${ApiConstants.chargerbnbApiUrl}/$uid/$shareId/status?status=$status');
      final response = await http.patch(url);
      
      print('상태 변경 코드: ${response.statusCode}');
      print('상태 변경 내용: ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar('', '상태 변경 완료');
      } else{
        throw Exception('Failed to update status. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print("Error in statChange: $e");
      Get.snackbar("오류", "상태 변경 중 문제가 발생했습니다.");
    }
    finally {
      isLoading.value = false;
    }
    }
    
    Future <void> loadReview() async {
    isLoading.value = true;
    try {
      final rawreview = await fetchReview();
      bnbReview.assignAll(
        rawreview.map(
            (e) =>
                {
                  "reviewId": e['reviewId']?.toString() ?? '알 수 없음',
                  "id": e['id']?.toString() ?? '알 수 없음',
                  "name": e['name']?.toString() ?? '알 수 없음',
                  "uid": e['uid']?.toString() ?? '알 수 없음',
                  "userName": e['userName']?.toString() ?? '알 수 없음',
                  "rating":  e['rating'] ?? 0,
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
    } else{
      throw Exception('Failed to fetch review');
    }
  }

  Future <void> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;
      
      final url = Uri.parse('${ApiConstants.reviewBaseUrl}/delete/$uid/$reviewId');
      final response = await http.delete(url);

      print("리뷰 삭제 응답 코드: ${response.statusCode}");
      print("리뷰 삭제 내용: ${utf8.decode(response.bodyBytes)}");

      if(response.statusCode == 200) {
        Get.snackbar('', '리뷰가 삭제되었습니다.', snackPosition: SnackPosition.BOTTOM);
        loadReview();
      } else {
        Get.snackbar('', '리뷰 삭제를 실패하었습니다.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  }
