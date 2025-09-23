import 'package:evfinder_front/Controller/register_charge_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/register_charge_controller.dart';

class RegisterChargeView extends GetView<RegisterChargeController> {
  const RegisterChargeView({super.key});
  static String route = "/register";

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
                      "충전소의 기본 정보를 입력해주세요.",
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
                              TextSpan(text: '호스트 이름'),
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

                    // 충전소 이름
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '충전소 이름'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 프리미엄 충전소",
                      ),
                    ),

                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '주소'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 서울특별시 학동로 123-45",
                      ),
                    ),

                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '충전기 타입'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 완속",
                      ),
                    ),

                    // 운영 시간 (시작~종료)
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '운영 시간'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 09:00-22:00",
                      ),
                    ),

                    // 파워 타입
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '파워 타입'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 50kW",
                      ),
                    ),

                    // 가격
                    TextFormField(
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black), // 기본 라벨 스타일
                            children: [
                              TextSpan(text: '가격'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 350",
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          //등록 구현해야 함
                        },
                        child: const Text("등록"),
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
