import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/profile_controller.dart';
import '../View/Widget/profile_card.dart';
import 'package:evfinder_front/View/Widget/reserv_user_card.dart';
import 'package:intl/intl.dart';

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
          const ProfileCard(), // 지금은 하드 코딩
          const SizedBox(height: 20),
          const Divider(thickness: 1.5, endIndent: 20, indent: 20),

          // 본문
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.reserveStation.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: Text('예약 내역이 없습니다.')),
                      );
                    }
                    return Column(
                      children: controller.reserveStation.map((reservation) {
                        String dateText = '-';
                        String timeText = '-';

                        final startTimeString = reservation['startTime'];
                        final endTimeString = reservation['endTime'];

                        if (startTimeString != null && endTimeString != null) {
                          // 1. ISO 8601 형식의 문자열을 DateTime 객체로 파싱
                          final startTime = DateTime.parse(startTimeString);
                          final endTime = DateTime.parse(endTimeString);

                          // 년-월-일 형식
                          dateText = DateFormat('yyyy-MM-dd').format(startTime);

                          // 시간:분:초 형식
                          final startTimePart = DateFormat('HH시mm분ss초').format(startTime);
                          final endTimePart = DateFormat('HH시mm분ss초').format(endTime);

                          timeText = '$startTimePart-$endTimePart';
                        }

                        return ReservUserCard(stationName: '공유 충전소', address: '서울 학동로 123-45', rating: 4.8, statusText: '예약 확정', dateText: dateText, timeText: timeText);
                      }).toList(),
                    );
                  }),

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
                      child: const Text('비밀번호 변경', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: controller.handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7280),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('로그아웃', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: controller.confirmDeleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('회원 탈퇴', style: TextStyle(fontSize: 18, color: Colors.white)),
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
