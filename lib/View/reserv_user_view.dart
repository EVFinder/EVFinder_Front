import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text("예약 관리"), backgroundColor: Colors.white),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reserveStation.isEmpty) {
          return const Center(child: Text("예약 내역이 없습니다."));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: controller.reserveStation.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final reservation = controller.reserveStation[index];
            String dateText = '-';
            String timeText = '-';

            final shareId = reservation['shareId'];
            final startTimeString = reservation['startTime'];
            final endTimeString = reservation['endTime'];
            final String reserveId = reservation['id'];
            // final MyReview = controller.userReview.contains(shareId);
            final MyReview = controller.userReview.any((e) => e['id'] == shareId);

            DateTime? startTime;
            DateTime? endTime;

            if (startTimeString != null) {
              startTime = DateTime.parse(startTimeString).toLocal();
            }
            if (endTimeString != null) {
              endTime = DateTime.parse(endTimeString).toLocal();
            }

            if (startTime != null && endTime != null) {
              // 년-월-일 형식
              final startdateText = DateFormat('yyyy-MM-dd').format(startTime);
              final enddateText = DateFormat('yyyy-MM-dd').format(endTime);

              dateText = (startdateText == enddateText) ? startdateText : '$startdateText-$enddateText';
              // 시간:분:초 형식
              final startTimePart = DateFormat('HH시 mm분').format(startTime);
              final endTimePart = DateFormat('HH시 mm분').format(endTime);

              timeText = '$startTimePart-$endTimePart';
            }
            final now = DateTime.now().toLocal();
            bool isExpired = false;
            bool isLockEdit = false;

            if (startTime != null) {
              final start = DateTime(startTime.year, startTime.month, startTime.day);
              final nowDate = DateTime(now.year, now.month, now.day);
              if (start.isBefore(nowDate)) {
                isExpired = true;
              }
            }
            if (endTime != null && endTime.isBefore(now)) {
              isExpired = true;
            }
            if (!isExpired && startTime != null) {
              if (now.isAfter(startTime.subtract(const Duration(hours: 1)))) {
                isLockEdit = true;
              }
            }
            final statusText = isExpired ? '만료된 예약입니다.' : (isLockEdit ? '수정 불가능한 예약입니다' : '예약 확정');

            final onCancel = (isExpired || isLockEdit)
                ? null
                : () {
                    controller.confirmDeleteReverse(reserveId);
                  };

            final onUpdate = (isExpired || isLockEdit)
                ? null
                : () {
                    Get.toNamed("/reserv", arguments: {'reservation': reservation});
                    ReservController recontroller = Get.find<ReservController>();
                    recontroller.selectMode();
                  };
            final onWriteReview = MyReview
                ? null
                : () async {
                    final ok = await Get.toNamed(
                      "/reviewWrite",
                      arguments: {'reservation': reservation},
                    );

                    // 작성 성공 시 Set에 추가해서 즉시 숨김
                    if (ok == true) {
                      controller.userReview.add({"id": shareId});
                      // controller.userReview.refresh(); RxList는 add로 반응
                    }
                  };

            return ReservUserCard(
              stationName: reservation['stationName'],
              address: reservation['address'],
              rating: (reservation['rating'] ?? 0.0) * 1.0,
              statusText: statusText,
              dateText: dateText,
              timeText: timeText,
              onCancel: onCancel,
              onUpdate: onUpdate,
              onWriteReview: onWriteReview,
              //     () {
              //   Get.toNamed("/reviewWrite", arguments: {'reservation': reservation});
              // }
            );
          },
        );
      }),
    );
  }
}
