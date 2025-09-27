import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

Widget buildStatItem(String label, String count, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: Colors.white, size: Get.size.width * 0.06),
      SizedBox(height: Get.size.height * 0.005),
      Text(
        count,
        style: TextStyle(color: Colors.white, fontSize: Get.size.width * 0.045, fontWeight: FontWeight.bold),
      ),
      Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: Get.size.width * 0.03),
      ),
    ],
  );
}
