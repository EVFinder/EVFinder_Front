import 'package:evfinder_front/View/Widget/reserv_timechip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

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
    return Obx(
      () => AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: isVisible.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Container(
          width: double.infinity,
          // constraints와 SingleChildScrollView 제거
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Column(
            // SingleChildScrollView 제거
            children: [
              // 캘린더
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: accentColor.withOpacity(0.3), shape: BoxShape.circle),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  onDateSelected?.call(selectedDay);
                },
                selectedDayPredicate: (day) {
                  return selectedDate != null && isSameDay(selectedDate, day);
                },
              ),

              // 구분선
              Container(height: 1, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 16)),

              // 시간 선택
              ReservTimechipWidget(
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
