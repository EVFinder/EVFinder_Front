import 'package:evfinder_front/Controller/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  static String route = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: Text("회원가입")),
      body: SafeArea(
        child: Obx(
          () => // 여기가 핵심!
          controller.isLoading.value
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981))),
                      SizedBox(height: 16),
                      Text('회원가입 중...', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 로고 섹션
                      Column(
                        children: [
                          const Text(
                            'EVFinder',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                          const Text('새로운 계정을 만들어보세요', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 회원가입 카드
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 이메일 입력
                            _buildInputField(
                              label: '이메일',
                              controller: controller.emailController,
                              isPhone: false,
                              hintText: '이메일을 입력하세요',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),

                            // 비밀번호 입력
                            _buildInputField(
                              label: '비밀번호',
                              controller: controller.passwordController,
                              isPhone: false,
                              hintText: '비밀번호를 입력하세요',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),

                            // 비밀번호 확인
                            _buildInputField(
                              label: '비밀번호 확인',
                              controller: controller.confirmPasswordController,
                              isPhone: false,
                              hintText: '비밀번호를 다시 입력하세요',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),

                            // 이름
                            _buildInputField(label: '이름', controller: controller.nameController, isPhone: false, hintText: '이름을 입력하세요', icon: Icons.person_outline),
                            const SizedBox(height: 24),

                            // 전화번호
                            _buildInputField(
                              label: '전화번호',
                              controller: controller.phoneNumController,
                              isPhone: true,
                              hintText: '전화번호를 입력하세요',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 32),

                            // 회원가입 버튼
                            Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value ? null : () => controller.handleSignup(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                  disabledBackgroundColor: const Color(0xFF9CA3AF),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      )
                                    : const Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 추가 정보
                      const Text(
                        '가입하시면 이용약관과 개인정보처리방침에 동의하게 됩니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPhone,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isPhone
            ? Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                  ),
                  SizedBox(width: Get.size.width * 0.01),
                  Text("*", style: TextStyle(color: Colors.red)),
                  Text(" (하이픈 없이 숫자만 입력)", style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
              ),

        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
