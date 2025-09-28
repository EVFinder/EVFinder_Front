import 'package:evfinder_front/Controller/register_charge_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/reserv_controller.dart';

class ReservView extends GetView<ReservController> {
  const ReservView({super.key});
  static String route = "/reserv";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("충전소 예약"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    const Text(
                      "기본 정보 입력",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "예약 정보를 입력해주세요.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),

                    // 연락처
                    TextFormField(
                      controller: controller.contactController,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '연락처'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 010-1234-5678",
                      ),
                    ),

                    // 시작 시간
                    TextFormField(
                      controller: controller.startController,
                      readOnly: true, // 사용자가 직접 입력하는 것을 막습니다.
                      decoration: InputDecoration(
                        hintText: "시작 시간을 선택하세요",
                      ),
                      onTap: () async {
                        // 1. 날짜 선택기 실행
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );

                          if (pickedTime != null) {
                            final dateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            controller.startController.text = dateTime.toIso8601String();
                          }
                        }
                      },
                    ),

                    TextFormField(
                      controller: controller.endController,
                      readOnly: true, // 사용자가 직접 입력하는 것을 막습니다.
                      decoration: InputDecoration(
                        hintText: "종료 시간을 선택하세요",
                      ),
                      onTap: () async {
                        // 1. 날짜 선택기 실행
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );

                          if (pickedTime != null) {
                            final dateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            ); //toUtc(). 뻄
                            controller.endController.text = dateTime.toIso8601String();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                            controller.reserv(context);
                            Get.toNamed("/main");
                        },
                        child: const Text("예약"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
