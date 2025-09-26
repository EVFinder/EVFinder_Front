import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/reservManagement_controller.dart';
import 'package:evfinder_front/View/Widget/reserv_host_card.dart';
import 'package:intl/intl.dart';

class ReservManagementView extends GetView<ReservManagementController> {
  const ReservManagementView({super.key});
  static String route = "/management";

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

        if (controller.customer.isEmpty) {
          return const Center(child: Text("예약 내역이 없습니다."));
        }

        return ListView.builder(
          itemCount: controller.customer.length,
          itemBuilder: (context, index) {
            final reservation = controller.customer[index];

            String dateText = '-';
            String timeText = '-';
            final startTimeString = reservation['startTime'];
            final endTimeString = reservation['endTime'];

            if (startTimeString != null && endTimeString != null) {
              try {
                final startTime = DateTime.parse(startTimeString);
                final endTime = DateTime.parse(endTimeString);

                dateText = DateFormat('MM월 dd일').format(startTime);
                timeText = '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
              } catch (e) {
                print("날짜 파싱 에러: $e");
              }
            }

            return ReservHostCard(
              statusText: '예약 확정',
              userName: reservation['userName'] ?? '정보 없음',
              userPhone: reservation['userPNumber'] ?? '정보 없음',
              dateText: dateText,
              timeText: timeText,
            );
          },
        );
      }),
    );
  }
}
