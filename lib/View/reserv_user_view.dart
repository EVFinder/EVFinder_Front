import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evfinder_front/View/Widget/reserv_host_card.dart';
import 'package:evfinder_front/View/Widget/reserv_user_card.dart';
import 'package:intl/intl.dart';
import '../Controller/reserv_controller.dart';
import '../Controller/reserv_user_controller.dart';

class ReservUserView extends GetView<ReservUserController> {
  const ReservUserView({super.key});
  static String route = "/reservUser";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("예약 관리"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reserveStation.isEmpty) {
          return const Center(child: Text("예약 내역이 없습니다."));
        }

        return Column(
          children: controller.reserveStation.map((reservation) {
            String dateText = '-';
            String timeText = '-';

            final startTimeString = reservation['startTime'];
            final endTimeString = reservation['endTime'];
            final String reserveId = reservation['id'];

            if (startTimeString != null && endTimeString != null) {
              // 1. ISO 8601 형식의 문자열을 DateTime 객체로 파싱
              final startTime = DateTime.parse(startTimeString);
              final endTime = DateTime.parse(endTimeString);

              // 년-월-일 형식
              dateText = DateFormat('yyyy-MM-dd').format(startTime);

              // 시간:분:초 형식
              final startTimePart = DateFormat('HH시mm분ss초').format(startTime);
              final endTimePart = DateFormat('HH시mm분ss초').format(endTime);

              timeText = '$startTimePart-$endTimePart';
            }
            return ReservUserCard(
              stationName: reservation['stationName'],
              address: reservation['address'],
              rating: 4.8,
              statusText: '예약 확정',
              dateText: dateText,
              timeText: timeText,
              onCancel: () {
                controller.confirmDeleteReverse(reserveId);
              },
              onUpdate: () {
                print("수정 전달 데이터 $reservation");
                Get.toNamed("/reserv", arguments : {'type': ReserveType.update, 'reservation': reservation});
              },
            );
          }).toList(),
        );
      }),
    );
  }
}
