import 'package:evfinder_front/Controller/payment_history_controller.dart';
import 'package:evfinder_front/View/Widget/payment_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evfinder_front/View/Widget/reserv_user_card.dart';
import 'package:intl/intl.dart';
import '../Controller/reserv_controller.dart';


class PaymentHistoryView extends GetView<PaymentHistoryController> {
  const PaymentHistoryView({super.key});

  static String route = "/paymentHistory";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text("결제 내역"), backgroundColor: Colors.white),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.payHistory.isEmpty) {
          return const Center(child: Text("예약 내역이 없습니다."));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: controller.payHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final pay = controller.payHistory[index];

            final itemName = pay['itemName'];
            final amount = pay['amount'];
            final status = pay['status'];
            final approvedAt = pay['approvedAt'].toString(); //결제 시간
            final cancelledAt = pay['cancelledAt'].toString(); //취소 시간
            final tid = pay['paymentId'];

            String? picked = status == 'SUCCESS' ? approvedAt : (status == 'CANCELLED' ? cancelledAt : null);

            final createdAt = (() {
              if (picked == null || picked.isEmpty || picked == 'null') {
                return DateTime.now();
              }
              final normalized = picked.replaceFirstMapped(RegExp(r'\.(\d{1,9})'), (m) {
                var frac = m.group(1)!;
                if (frac.length > 6) frac = frac.substring(0, 6);
                if (frac.length < 6) frac = frac.padRight(6, '0');
                return '.${frac}';
              });

              final dt = DateTime.tryParse(normalized)
                  ?? DateTime.tryParse(picked.split('.').first);
              if (dt == null) return DateTime.now();
              return dt.isUtc ? dt.toLocal() : dt;
            })();

            // final createdAt = (picked != null && picked.isNotEmpty)
            //     ? DateTime.parse(picked).toLocal()
            //     : DateTime.now();

            return PaymentCard(
                title: itemName,
                createdAt: createdAt,
                amount: amount,
                status: status,
                onCancelTap: () => controller.cancelPayment(tid: tid),
            );
          },
        );
      }),
    );
  }
}
