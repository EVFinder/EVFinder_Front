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
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("예약 관리"),
        backgroundColor: Colors.white,
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

            DateTime? startTime;
            DateTime? endTime;

            if(startTimeString != null) {
              startTime = DateTime.parse(startTimeString).toLocal();
            }
            if(endTimeString != null) {
              endTime = DateTime.parse(endTimeString).toLocal();
            }
            if(startTime != null && endTime != null) {
              final startdateText = DateFormat('yyyy-MM-dd').format(startTime);
              final enddateText = DateFormat('yyyy-MM-dd').format(endTime);

              dateText = (startdateText == enddateText) ? startdateText : '$startdateText-$enddateText';

              final startTimePart = DateFormat('HH시 mm분').format(startTime);
              final endTimePart = DateFormat('HH시 mm분').format(endTime);

              timeText = '$startTimePart-$endTimePart';
            }
            final now = DateTime.now().toLocal();
            bool isExpired = false;

            if(startTime != null) {
              final start = DateTime(startTime.year, startTime.month, startTime.day);
              final nowDate = DateTime(now.year, now.month, now.day);
              if(start.isBefore(nowDate)){
                isExpired = true;
              }
            }
            if(endTime != null && endTime.isBefore(now)) {
              isExpired = true;
            }

            final statusText = isExpired ? '만료된 예약입니다.' : '예약 확정';
            // if (startTimeString != null && endTimeString != null) {
            //   try {
            //     final startTime = DateTime.parse(startTimeString);
            //     final endTime = DateTime.parse(endTimeString);
            //
            //     dateText = DateFormat('MM월 dd일').format(startTime);
            //     timeText = '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
            //   } catch (e) {
            //     print("날짜 파싱 에러: $e");
            //   }
            // }

            return ReservHostCard(
              statusText: statusText,
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
