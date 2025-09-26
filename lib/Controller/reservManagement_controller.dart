import 'dart:convert';

import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservManagementController extends GetxController {
  final customer = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomer();
  }
String? reserveId;
  Future<void> loadCustomer() async {
    isLoading.value = true;

    final arguments = Get.arguments as Map<String, dynamic>?;
    if(arguments != null) {
      reserveId = arguments['id']?.toString();
    }
    try {
      final rawCustomer = await fetchCustomer();
      customer.assignAll(
        rawCustomer.map(
            (e) =>
                {
                  "id": e['id']?.toString() ?? '알 수 없음',
                  "shareId": e['shareId']?.toString() ?? '알 수 없음',
                  "ownerUid": e['ownerUid']?.toString() ?? '알 수 없음',
                  "userName": e['userName']?.toString() ?? '알 수 없음',
                  "userPNumber": e['userPNumber']?.toString() ?? '알 수 없음',
                  "startTime": e['startTime']?.toString() ?? '알 수 없음',
                  "endTime": e['endTime']?.toString() ?? '알 수 없음',
                  "createdAt": e['createdAt']?.toString() ?? '알 수 없음'
                },
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomer() async {
    final url = Uri.parse('${ApiConstants.reservApiBaseUrl}/share/${reserveId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else{
      throw Exception('Failed to fetch customer');
    }
  }
}