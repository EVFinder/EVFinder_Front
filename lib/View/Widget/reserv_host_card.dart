import 'package:flutter/material.dart';

class ReservHostCard extends StatelessWidget {
  const ReservHostCard({
    super.key,
    required this.statusText,      // 예: 예약 확정
    this.statusColor = const Color(0xFF7C3AED), // 보라색 칩
    required this.userName,        // 예: 홍길동
    required this.userPhone,
    required this.dateText,
    required this.timeText,        // 예: 14:00
  });

  final String statusText;
  final Color statusColor;
  final String userName;
  final String userPhone;
  final String dateText;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('고객 정보', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(userName),
                      Text(userPhone),
                      const Text('시간', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                          Text(dateText),
                          Text(timeText),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
          ],
        ),
        ],
      ),
      ),
    );
  }
}
