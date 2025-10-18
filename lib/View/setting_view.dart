import 'package:evfinder_front/Controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Controller/profile_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  static String route = '/setting';

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.find<ProfileController>();
    return Scaffold(
      appBar: AppBar(title: const Text("환경 설정"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 본문
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await openAppSettings();
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
                                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), shape: BoxShape.circle),
                                    child: const Icon(Icons.location_on, size: 22, color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      '권한 설정',
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
                      SizedBox(height: Get.size.height * 0.01),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: profileController.handleChangePassword,
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
                                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), shape: BoxShape.circle),
                                    child: const Icon(Icons.lock_rounded, size: 22, color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      '비밀번호 변경',
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
                      SizedBox(height: Get.size.height * 0.01),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: profileController.confirmDeleteAccount,
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
                                    decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.12), shape: BoxShape.circle),
                                    child: const Icon(Icons.person_remove_rounded, size: 22, color: Color(0xFFEF4444)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      '회원 탈퇴',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
