import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/changePassword_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
  static String route = "/password";

  @override
  Widget build(BuildContext context) {

    InputDecoration _dec(String hint, {bool dense = false, Widget? prefix, Widget? suffix}) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF34D399)), // emerald-400
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text("비밀번호 변경"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                // 상단 아이콘 + 타이틀
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFD1FAE5), // emerald-100
                  ),
                  child: const Icon(Icons.lock_outline, size: 36, color: Color(0xFF10B981)), // emerald-500
                ),
                const SizedBox(height: 16),
                const Text(
                  '비밀번호 변경',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  '보안을 위해 새로운 비밀번호를 설정해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),

                // 카드
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 18),
                            const Text('새 비밀번호', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                              obscureText: true,
                              controller: controller.passwordController,
                              decoration: _dec(
                                '새 비밀번호를 입력하세요',
                                prefix: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
                              ),
                            ),

                            const SizedBox(height: 18),
                            const Text('비밀번호 확인', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                              obscureText: true,
                              controller: controller.confirmController,
                              decoration: _dec(
                                '새 비밀번호를 다시 입력하세요',
                                prefix: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
                              ),
                            ),

                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.handleChangePassword(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF34D399),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  controller.isLoading.value ? '변경 중…' : '비밀번호 변경',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              )),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
