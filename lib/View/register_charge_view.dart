import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/register_charge_controller.dart';

class RegisterChargeView extends GetView<RegisterChargeController> {
  const RegisterChargeView({super.key});
  static String route = "/register";

  // 색/스타일
  static const _textDark = Color(0xFF0F172A);
  static const _textSub  = Color(0xFF6B7280);
  static const _border   = Color(0xFFE5E7EB);
  static const _panelBg  = Color(0xFFF7F9FC);
  static const _primary  = Color(0xFF0F172A);   // 주소 찾기 버튼
  static const _accent   = Color(0xFF10B981);   // 등록 버튼

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _textSub),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _accent, width: 1.6),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _label(IconData icon, String text, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textSub),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        if (required)
          const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _panelBg,
      appBar: AppBar(
        title: const Text("새 충전소 등록"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    const Text("기본 정보 입력",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textDark)),
                    const SizedBox(height: 6),
                    const Text("충전소의 기본 정보를 입력해주세요.",
                        style: TextStyle(fontSize: 13, color: _textSub)),
                    const SizedBox(height: 18),

                    // 연락처
                    _label(Icons.call_rounded, '연락처', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _decoration("연락처를 입력하세요"),
                    ),

                    const SizedBox(height: 16),

                    // 충전소 이름
                    _label(Icons.apartment_rounded, '충전소 이름', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.chargeNameContrller,
                      decoration: _decoration("충전소 이름을 입력하세요"),
                    ),

                    const SizedBox(height: 16),

                    // 주소
                    _label(Icons.place_outlined, '주소', required: true),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: controller.openPostcode,
                        style: TextButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('주소 찾기', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.addrController,
                      readOnly: true,
                      decoration: _decoration("주소를 입력하세요"),
                    ),
                    const SizedBox(height: 12),
                    _label(Icons.map_outlined, '상세 주소', required: false),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.detailaddrController,
                      decoration: _decoration("상세 주소를 입력하세요"),
                    ),

                    const SizedBox(height: 16),

                    // 충전기 타입 (텍스트 입력 유지)
                    _label(Icons.bolt_rounded, '충전기 타입', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.chargeTypeController,
                      decoration: _decoration("예: 완속 / 급속 등"),
                    ),

                    const SizedBox(height: 16),

                    // 운영 상태 (드롭다운)
                    _label(Icons.toggle_on_rounded, '운영 상태', required: true),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedStat.value,
                      items: controller.statOptions.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => controller.selectedStat.value = v,
                      decoration: _decoration("선택하세요"),
                    )),

                    const SizedBox(height: 16),

                    // 파워 타입 (텍스트 입력 유지)
                    _label(Icons.speed_rounded, '파워 타입', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.powerController,
                      decoration: _decoration("예: 50kW, 7kW 등"),
                    ),

                    const SizedBox(height: 16),

                    // 가격
                    _label(Icons.attach_money_rounded, '가격', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.priceContoller,
                      keyboardType: TextInputType.number,
                      decoration: _decoration("가격을 입력하세요").copyWith(suffixText: '원/kWh'),
                    ),

                    const SizedBox(height: 22),

                    // 등록 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // 동작은 기존 그대로 사용 (원하면 이동 제거 가능)
                          controller.register(context);
                          Get.toNamed("/main");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
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
