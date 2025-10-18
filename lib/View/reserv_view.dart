import 'package:evfinder_front/View/Widget/reserv_timechip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/reserv_controller.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Widget/reserv_calendar_widget.dart';

class ReservView extends GetView<ReservController> {
  const ReservView({super.key});

  static String route = "/reserv";

  // 스타일
  static const _textDark = Color(0xFF0F172A);
  static const _textSub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _panelBg = Color(0xFFF7F9FC);
  static const _accent = Color(0xFF10B981);

  InputDecoration _decoration(String hint, {Widget? prefix, Widget? suffix}) {
    return InputDecoration(
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
      prefixIcon: prefix == null ? null : Padding(padding: const EdgeInsets.only(left: 10, right: 6), child: prefix),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffix,
    );
  }

  Widget _label(IconData icon, String text, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textSub),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
          ),
      ],
    );
  }

  Widget _payMethodTile({required String id, required String title, required bool selected, required VoidCallback onTap, String? subtitle, bool tall = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(tall ? 18 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _accent : _border, width: selected ? 1.6 : 1),
          boxShadow: selected ? [BoxShadow(color: _accent.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
                  ),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: _textSub))],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? _accent : _border, width: selected ? 6 : 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RxBool isStartTimeVisible = false.obs;
    final RxBool isEndTimeVisible = false.obs;
    final RxString payMethod = 'kakao'.obs;

    return Scaffold(
      backgroundColor: _panelBg,
      appBar: AppBar(title: const Text("충전소 예약"), elevation: 0, backgroundColor: Colors.white, foregroundColor: _textDark),
      body: Obx(
        () => controller.isFetched.value == true
            ? SingleChildScrollView(
                // 전체를 감싸는 하나의 스크롤뷰
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
                            const Text(
                              "기본 정보 입력",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textDark),
                            ),
                            const SizedBox(height: 6),
                            const Text("예약 정보를 입력해주세요.", style: TextStyle(fontSize: 13, color: _textSub)),
                            const SizedBox(height: 18),

                            Column(
                              children: [
                                // 연락처
                                _label(Icons.call_rounded, '연락처', required: true),
                                const SizedBox(height: 8),
                                controller.phone == ''
                                    ? TextFormField(
                                        controller: controller.contactController,
                                        keyboardType: TextInputType.phone,
                                        decoration: _decoration("예: 010-1234-5678", prefix: const Icon(Icons.call_rounded, size: 18, color: _textSub)),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            // Icon(Icons.call_rounded, size: 18, color: _textSub),
                                            SizedBox(width: Get.size.width * 0.02),
                                            Text(controller.phone!, style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // 시작 시간
                            _label(Icons.play_circle_fill_rounded, '시작 시간', required: true),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                TextFormField(
                                  controller: controller.startController,
                                  readOnly: true,
                                  decoration: _decoration(
                                    "시작 시간을 선택하세요",
                                    prefix: const Icon(Icons.access_time_rounded, size: 18, color: _textSub),
                                    suffix: Obx(
                                      () => AnimatedRotation(
                                        turns: isStartTimeVisible.value ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 300),
                                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    isStartTimeVisible.toggle();
                                    if (isEndTimeVisible.value) {
                                      isEndTimeVisible.value = false;
                                    }
                                  },
                                ),

                                GetBuilder<ReservController>(
                                  builder: (controller) => ReservCalendarWidget(
                                    isVisible: isStartTimeVisible,
                                    controller: controller.startController,
                                    selectedDate: controller.selectedStartDate,
                                    borderColor: Colors.grey.shade300,
                                    accentColor: _accent,
                                    onDateSelected: (date) {
                                      controller.selectStartDate(date);
                                    },
                                    onDateTimeSelected: () {
                                      print('시작 시간이 선택되었습니다: ${controller.startController.text}');
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 종료 시간
                            _label(Icons.stop_circle_rounded, '종료 시간', required: true),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                TextFormField(
                                  controller: controller.endController,
                                  readOnly: true,
                                  decoration: _decoration(
                                    "종료 시간을 선택하세요",
                                    prefix: const Icon(Icons.access_time_filled_rounded, size: 18, color: _textSub),
                                    suffix: Obx(
                                      () => AnimatedRotation(
                                        turns: isEndTimeVisible.value ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 300),
                                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    isEndTimeVisible.toggle();
                                    if (isStartTimeVisible.value) {
                                      isStartTimeVisible.value = false;
                                    }
                                  },
                                ),

                                GetBuilder<ReservController>(
                                  builder: (controller) => ReservCalendarWidget(
                                    isVisible: isEndTimeVisible,
                                    controller: controller.endController,
                                    selectedDate: controller.selectedEndDate,
                                    borderColor: Colors.grey.shade300,
                                    accentColor: _accent,
                                    onDateSelected: (date) {
                                      controller.selectEndDate(date);
                                    },
                                    onDateTimeSelected: () {
                                      // Controller의 검증 메서드 사용
                                      if (controller.validateEndTime()) {
                                        print('종료 시간이 선택되었습니다: ${controller.endController.text}');
                                      }
                                    },
                                    // disabledDates: ['2025-10-21'],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),
                            const SizedBox(height: 16),
                            _label(Icons.payments_rounded, '결제 수단 선택'),
                            const SizedBox(height: 10),

                            Obx(
                              () => Column(
                                children: [
                                  _payMethodTile(id: 'kakao', title: '카카오페이', selected: payMethod.value == 'kakao', onTap: () => payMethod.value = 'kakao'),
                                  const SizedBox(height: 10),
                                  _payMethodTile(id: 'naver', title: '네이버페이', selected: payMethod.value == 'naver', onTap: () => payMethod.value = 'naver'),
                                  const SizedBox(height: 10),
                                  _payMethodTile(id: 'toss', title: '토스페이', selected: payMethod.value == 'toss', onTap: () => payMethod.value = 'toss'),

                                  const SizedBox(height: 16),

                                  _payMethodTile(
                                    id: 'card',
                                    title: '카드 추가',
                                    subtitle: '신용카드 또는 체크카드를 등록해주세요',
                                    selected: payMethod.value == 'card',
                                    onTap: () => payMethod.value = 'card',
                                    tall: true,
                                  ),
                                ],
                              ),
                            ),

                            // 예약 버튼
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.reserv(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                child: const Text("예약"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
