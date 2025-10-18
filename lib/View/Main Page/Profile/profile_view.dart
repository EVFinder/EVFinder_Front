import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Pay/payment_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controller/MainPage/Profile/profile_controller.dart';
import '../../Widget/Profile/chatbot_card.dart';
import '../../Widget/Profile/profile_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static String route = "/profile";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(thickness: 1.5, endIndent: 20, indent: 20),
            Obx(() => ProfileCard(userName: controller.userName.value, email: controller.email.value)),
            const SizedBox(height: 10),
            const Divider(thickness: 1.5, endIndent: 20, indent: 20),

            // 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    //챗봇 버튼
                    const SizedBox(height: 8),
                    ChatbotCard(onTap: () => Get.toNamed('/chatbot')),
                    const SizedBox(height: 18),

                    // 버튼들
                    // --- 버튼들 (카드형 리스트) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Get.toNamed("/reservUser");
                            await controller.loadreservCharge();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAF8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE7EBE5)),
                              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.12), shape: BoxShape.circle),
                                  child: const Icon(Icons.event_available_rounded, size: 22, color: Color(0xFF3B82F6)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    '내 예약 확인하기',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Get.toNamed("/paymentHistory"); //결제 내역 확인 페이지로 이동하도록
                            if (Get.isRegistered<PaymentHistoryController>()) {
                              // Get.find<PaymentHistoryController>().loadreservCharge();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAF8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE7EBE5)),
                              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.12), shape: BoxShape.circle),
                                  child: const Icon(Icons.receipt_long_outlined, size: 22, color: Color(0xFF3B82F6)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    '결제 내역 확인',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final accentColor = const Color(0xFF10B981);
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    Icon(Icons.logout_rounded, color: accentColor, size: 24),
                                    const SizedBox(width: 8),
                                    const Text("로그아웃", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                content: Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text("${controller.userName}님 정말 로그아웃 하시겠어요?", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Container(
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                    child: TextButton(
                                      onPressed: () async {
                                        controller.handleLogout();
                                      },
                                      child: const Text(
                                        '로그아웃',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAF8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE7EBE5)),
                              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: const Color(0xFF9CA3AF).withOpacity(0.18), shape: BoxShape.circle),
                                  child: const Icon(Icons.logout_rounded, size: 22, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    '로그아웃',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
