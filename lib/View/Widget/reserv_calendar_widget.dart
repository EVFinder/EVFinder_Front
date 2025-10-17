import 'package:evfinder_front/Controller/reserv_controller.dart';
import 'package:evfinder_front/View/Widget/reserv_timechip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Controller/charge_detail_controller.dart';

class ReservCalendarWidget extends StatelessWidget {
  final RxBool isVisible;
  final TextEditingController controller;
  final VoidCallback? onDateTimeSelected;
  final Color borderColor;
  final Color accentColor;
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;

  const ReservCalendarWidget({
    Key? key,
    required this.isVisible,
    required this.controller,
    this.onDateTimeSelected,
    this.borderColor = const Color(0xFFE5E7EB),
    this.accentColor = const Color(0xFF10B981),
    this.selectedDate,
    this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChargeDetailController chargeController = Get.find<ChargeDetailController>();

    return Obx(
      () => AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: isVisible.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Column(
            children: [
              // 캘린더 - Obx로 감싸서 예약 데이터 변화 감지
              Obx(() {
                // reservedTimeSlots를 직접 참조하여 변화 감지
                final reservedSlots = chargeController.reservedTimeSlots.value;

                return TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: accentColor.withOpacity(0.3), shape: BoxShape.circle),
                    // 예약이 있는 날짜 마커 스타일
                    markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    // 비활성화된 날짜 스타일 (완전히 예약된 날짜)
                    disabledDecoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  // 비활성화할 날짜 지정
                  enabledDayPredicate: (day) {
                    // 기존 컨트롤러의 비활성화 로직 확인
                    if (chargeController.isDayDisabled(day)) {
                      return false;
                    }
                    // 과거 날짜 비활성화
                    if (day.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                      return false;
                    }
                    // 완전히 예약된 날짜 비활성화 (24시간 모두 예약)
                    String dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                    int reservedCount = reservedSlots.where((slot) => slot.startsWith(dateStr)).length;
                    return reservedCount < 24;
                  },
                  // 예약이 있는 날짜에 마커 표시
                  eventLoader: (day) {
                    String dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                    int reservedCount = reservedSlots.where((slot) => slot.startsWith(dateStr)).length;
                    if (reservedCount > 0 && reservedCount < 24) {
                      return ['reservation']; // 부분 예약
                    }
                    return [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    // 활성화된 날짜만 선택 가능
                    String dateStr = '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
                    int reservedCount = reservedSlots.where((slot) => slot.startsWith(dateStr)).length;

                    if (!selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1))) && reservedCount < 24) {
                      onDateSelected?.call(selectedDay);
                    }
                  },
                  selectedDayPredicate: (day) {
                    return selectedDate != null && isSameDay(selectedDate, day);
                  },
                );
              }),

              // 구분선
              Container(height: 1, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 16)),

              // 시간 선택
              ReservTimechipWidget(
                selectedDate: selectedDate, // 선택된 날짜 전달
                onTimeSelected: (period, time) {
                  if (selectedDate != null) {
                    String formattedDate = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                    controller.text = '$formattedDate $period $time';
                    isVisible.value = false;
                    onDateTimeSelected?.call();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('먼저 날짜를 선택해주세요')));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
