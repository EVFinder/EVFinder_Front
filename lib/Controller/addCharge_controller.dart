import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddChargeController extends GetxController {
  final hostchargeStation = <Map<String, dynamic>>[.obs;
  RxBool isLoading = false.obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUidAndCahrge();
  }

  Future<void> _loadUidAndCahrge() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    await loadHostCharge();
  }

 @override
 void dispose() {
   super.dispose();
 }

 Future<void> loadHostCharge() async {
    isLoading.value = true;

    try {
      final ra
    }
 }
}