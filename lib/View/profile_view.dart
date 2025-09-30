import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/profile_controller.dart';
import '../View/Widget/profile_card.dart';
import 'Widget/chatbot_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static String route = "/profile";

  @override
  Widget build(BuildContext context) {
    // 화면이 빌드될 때마다 예약 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadreservCharge();
    });

    return SafeArea(
      child: Column(
        children: [
          // const ProfileCard(
          //   userName: ,
          //   email: ,
          // ),
          SizedBox(height:Get.size.height * 0.03),
          Obx(() => ProfileCard(
              userName: controller.userName.value,
              email: controller.email.value
          )),
          const SizedBox(height: 20),
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
                      onTap: () => Get.toNamed("/reservUser"),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7EBE5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_available_rounded,
                                  size: 22, color: Color(0xFF3B82F6)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('내 예약 확인하기',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis),
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
                      onTap: controller.handleChangePassword,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7EBE5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  size: 22, color: Color(0xFF10B981)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('비밀번호 변경',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis),
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
                      onTap: controller.handleLogout,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7EBE5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CA3AF).withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.logout_rounded,
                                  size: 22, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('로그아웃',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis),
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
                      onTap: controller.confirmDeleteAccount,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7EBE5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_remove_rounded,
                                  size: 22, color: Color(0xFFEF4444)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('회원 탈퇴',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis),
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
    );
  }
}
