import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/reservManagement_controller.dart';
import 'package:evfinder_front/View/Widget/reserv_host_card.dart';

class ReservManagementView extends GetView<ReservManagementController> {
  const ReservManagementView({super.key});
  static String route = "/management";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("예약 관리"),
      ),
      body: ListView(
    padding: const EdgeInsets.symmetric(vertical: 8),
    children: const [
      ReservHostCard(
        stationName: '강남역 프리미엄 충전소',
        statusText: '예약 확정',
        userName: '홍길동',
        userPhone: '010-1234-5578',
        dateText: '01월 25일',
        timeText: '14:00-16:00',
      ),
    ],
    )
    );
  }
}