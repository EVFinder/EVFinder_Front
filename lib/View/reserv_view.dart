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
        title: const Text("새 충전소 등록"),
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

                    // 호스트 이름
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '예약자 이름'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 홍길동",
                      ),
                    ),
                    // 연락처
                    TextFormField(
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
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '시작 시간'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 09:00",
                      ),
                    ),

                    // 사용 시간
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '사용 시간'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 2시간",
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          //등록 구현해야 함
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
