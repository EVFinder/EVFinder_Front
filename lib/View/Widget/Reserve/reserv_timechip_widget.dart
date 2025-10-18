import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Charger/charge_detail_controller.dart';

class ReservTimechipWidget extends StatefulWidget {
  final Function(String, String)? onTimeSelected; // (period, time)
  final String? selectedPeriod;
  final String? selectedTime;
  final DateTime? selectedDate; // 선택된 날짜 추가

  const ReservTimechipWidget({
    Key? key,
    this.onTimeSelected,
    this.selectedPeriod,
    this.selectedTime,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<ReservTimechipWidget> createState() => _TimeSelectionWidgetState();
}

class _TimeSelectionWidgetState extends State<ReservTimechipWidget> {
  String? selectedPeriod;
  String? selectedTime;
  late ChargeDetailController chargeController;

  final Map<String, List<String>> timeSlots = {
    '오전': ['12:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00'],
    '오후': ['12:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00'],
  };

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.selectedPeriod;
    selectedTime = widget.selectedTime;
    chargeController = Get.find<ChargeDetailController>();

    // reservedTimeSlots 변화 감지를 위한 리스너 등록
    chargeController.reservedTimeSlots.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(ReservTimechipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 날짜가 변경되면 선택 초기화
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        selectedPeriod = null;
        selectedTime = null;
      });
    }
  }

  // 특정 시간이 예약되어 있는지 확인하는 메서드
  bool _isTimeSlotReserved(String period, String time) {
    if (widget.selectedDate == null) return false;

    String dateStr = '${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}';

    // 시간 형식 변환 (12시간 -> 24시간)
    int hour = int.parse(time.split(':')[0]);
    if (period == '오후' && hour != 12) {
      hour += 12;
    } else if (period == '오전' && hour == 12) {
      hour = 0;
    }

    String timeSlot = '$dateStr ${hour.toString().padLeft(2, '0')}:00';
    return chargeController.reservedTimeSlots.contains(timeSlot);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오전/오후 선택
          Row(children: [_buildPeriodButton('오전'), const SizedBox(width: 12), _buildPeriodButton('오후')]),

          const SizedBox(height: 24),

          // 시간 선택 (선택된 기간이 있을 때만 표시)
          if (selectedPeriod != null) ...[
            Text(
              selectedPeriod!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildTimeGrid(timeSlots[selectedPeriod!] ?? []),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final bool isSelected = selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
          selectedTime = null; // 기간 변경 시 시간 선택 초기화
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF10B981) : Colors.transparent,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTimeGrid(List<String> times) {
    return Wrap(
      spacing: 12, // 가로 간격
      runSpacing: 12, // 세로 간격
      children: times.map((time) => _buildTimeButton(time)).toList(),
    );
  }

  Widget _buildTimeButton(String time) {
    final bool isSelected = selectedTime == time;
    final bool isReserved = _isTimeSlotReserved(selectedPeriod!, time);

    return GestureDetector(
      onTap: isReserved ? null : () { // 예약된 시간이면 클릭 비활성화
        setState(() {
          selectedTime = time;
        });
        if (selectedPeriod != null) {
          widget.onTimeSelected?.call(selectedPeriod!, time);
        }
      },
      child: Container(
        width: 90, // 너비 증가
        height: 45, // 높이 증가
        decoration: BoxDecoration(
          color: isReserved
              ? Colors.grey.shade300 // 예약된 시간 배경색
              : isSelected
              ? Color(0xFF10B981)
              : Colors.transparent,
          border: Border.all(
              color: isReserved
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
              width: 1
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
                fontSize: 14,
                color: isReserved
                    ? Colors.grey.shade500 // 예약된 시간 텍스트 색상
                    : isSelected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w400
            ),
          ),
        ),
      ),
    );
  }
}
