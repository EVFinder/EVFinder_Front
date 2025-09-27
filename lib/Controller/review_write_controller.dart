import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'charge_detail_controller.dart';

class ReviewWriteController extends GetxController {
  final rating = 0.obs; //별점 저장
  RxBool isLoading = false.obs;
  final contentController = TextEditingController();
  final uid = ''.obs;

  String? shareId;
  String? stationName;
  String? reviewId;

  bool isUpdateMode = false;

  @override
  void onInit() {
    super.onInit();
    loadUid();
    handleArguments();
  }

  @override
  void dispose() {
    super.dispose();
    contentController.dispose();
  }

  void handleArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {

      if (arguments.containsKey('review')) {
        isUpdateMode = true;
        final reviewData = arguments['review'] as Map<String, dynamic>;
        print('전달 review: $reviewData');
        reviewId = reviewData['reviewId']?.toString();

        rating.value = reviewData['rating'] ?? 0;
        contentController.text = reviewData['content'] ?? '';
        print('수정 모드임');
      } else if (arguments.containsKey('station')) {
        isUpdateMode = false;
        final stationData = arguments['station'] as Map<String, dynamic>;
        shareId = stationData['id']?.toString();
        stationName = stationData['stationName']?.toString();
        print('작성 모드임');
      }
    }
  }

  Future<void> loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
  }
  //별점
  void setRating(int newRating) {
    rating.value = newRating;
  }

  Future <void> Review(BuildContext context) async {
    if (rating.value == 0) {
      Get.snackbar('알림', '별점을 선택해주세요.');
      return;
    }
    if (contentController.text.isEmpty) {
      Get.snackbar('알림', '리뷰 내용을 입력해주세요.');
      return;
    }

    final content = contentController.text;
    final headers = {'Content-Type': 'application/json'};

    try {
      http.Response response;
      String successMessage;
      if(isUpdateMode) {
        final url = Uri.parse('${ApiConstants.reviewBaseUrl}/update/${uid}/${reviewId}');
        response = await http.put(url,
          headers: headers,
          body: jsonEncode({
            'rating': rating.value,
            'content': content
          }),
        );
        successMessage = '수정이 완료되었습니다.';
      } else {
        final url = Uri.parse('${ApiConstants.reviewBaseUrl}/add/${uid}');
        response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'id': shareId,
          'name': stationName,
          'rating': rating.value,
          'content': content
        }),
        );
        successMessage = '등록이 완료되었습니다.';
      }
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        if (Get.isRegistered<ChargeDetailController>()) {
          Get.find<ChargeDetailController>().loadReview();
        }

        Get.back();
      }else {
        final msg = response.body.isNotEmpty ? response.body : '요청 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패(${response.statusCode}) : $msg')),
        );
      }
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
    }
  }
}
