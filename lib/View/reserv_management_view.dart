import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/reservManagement_controller.dart';

class ReservManagementView extends GetView<ReservManagementController> {
  const ReservManagementView({super.key});
  static String route = "/management";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("예약 관리"),
      ),
      body: Container(
        child: Text("예약 관리 내용"),
      ),
    );
  }
}