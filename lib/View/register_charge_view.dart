import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/register_charge_controller.dart';
import 'package:kpostal/kpostal.dart';

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
                      controller: controller.hostnameController,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '호스트 이름'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 홍길동",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 연락처
                    TextFormField(
                      controller: controller.phoneController,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '연락처'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 010-1234-5678",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 충전소 이름
                    TextFormField(
                      controller: controller.chargeNameContrller,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '충전소 이름'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 프리미엄 충전소",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 주소 섹션: 버튼 -> 주소 -> 상세주소
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 주소 찾기 버튼
                        TextButton(
                          onPressed: () {
                            controller.openPostcode();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            '주소 찾기',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 주소
                        TextFormField(
                          controller: controller.addrController,
                          readOnly: true,
                          decoration: InputDecoration(
                            label: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(text: '주소'),
                                  TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                                ],
                              ),
                            ),
                            hintText: "예: 서울특별시 강남구 학동로 123-45",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 상세주소
                        TextFormField(
                          controller: controller.detailaddrController,
                          decoration: InputDecoration(
                            labelText: "상세 주소",
                            hintText: "예: 지하1층, B5동 주차장",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 충전기 타입
                    TextFormField(
                      controller: controller.chargeTypeController,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '충전기 타입'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 완속",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 운영 상태
                    Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedStat.value,
                      items: controller.statOptions.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(controller.statOptions[key]!),
                        );
                      }).toList(),

                      onChanged: (String? newValue) {
                        controller.selectedStat.value = newValue;
                      },
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '운영 상태'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "선택하세요",
                        border: OutlineInputBorder(), // 테두리를 추가하면 더 보기 좋습니다.
                      ),
                    )),
                    const SizedBox(height: 12),

                    // 파워 타입
                    TextFormField(
                      controller: controller.powerController,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '파워 타입'),
                              TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        hintText: "예: 50kW",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 가격
                    TextFormField(
                      controller: controller.priceContoller,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black),
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
                          controller.register(context);
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