import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/profile_controller.dart';
import '../View/Widget/profile_card.dart';
import 'package:evfinder_front/View/Widget/reserv_user_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  static String route = "/profile";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const ProfileCard(), // 지금은 하드 코딩
          const SizedBox(height: 20),
          const Divider(thickness: 1.5, endIndent: 20, indent: 20),

          // 본문
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // ✅ 예약 카드 추가 위치
                  const ReservUserCard(
                    stationName: '공유 충전소',
                    address: '서울 학동로 123-45',
                    rating: 4.8,
                    statusText: '예약 확정',
                    dateText: '2025-09-18',
                    timeText: '14:00',
                    durationText: '2시간',
                  ),

                  const SizedBox(height: 15),

                  // 버튼들
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: controller.handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('비밀번호 변경',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      // ⛔️ () => controller.handleLogout 는 실행 안 됨
                      onPressed: controller.handleLogout, // ✅ 함수 참조로 전달
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7280),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('로그아웃',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: controller.deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('회원 탈퇴',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
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
