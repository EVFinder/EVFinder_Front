import 'package:flutter/material.dart';

class ReservTimechipWidget extends StatefulWidget {
  final Function(String, String)? onTimeSelected; // (period, time)
  final String? selectedPeriod;
  final String? selectedTime;

  const ReservTimechipWidget({Key? key, this.onTimeSelected, this.selectedPeriod, this.selectedTime}) : super(key: key);

  @override
  State<ReservTimechipWidget> createState() => _TimeSelectionWidgetState();
}

class _TimeSelectionWidgetState extends State<ReservTimechipWidget> {
  String? selectedPeriod;
  String? selectedTime;

  final Map<String, List<String>> timeSlots = {
    '오전': ['12:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00'],
    '오후': ['12:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00'],
  };

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.selectedPeriod;
    selectedTime = widget.selectedTime;
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
        if (selectedTime != null) {
          widget.onTimeSelected?.call(period, selectedTime!);
        }
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
    return Wrap(spacing: 8, runSpacing: 8, children: times.map((time) => _buildTimeButton(time)).toList());
  }

  Widget _buildTimeButton(String time) {
    final bool isSelected = selectedTime == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTime = time;
        });
        if (selectedPeriod != null) {
          widget.onTimeSelected?.call(selectedPeriod!, time);
        }
      },
      child: Container(
        width: 70,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF10B981) : Colors.transparent,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
