import 'package:flutter/material.dart';

class ReservHostCard extends StatelessWidget {
  const ReservHostCard({
    super.key,
    required this.statusText,                  // 예: 예약 확정
    // this.statusColor = const Color(0xFF7C3AED), // 보라색 칩
    required this.userName,                   // 예: 홍길동
    required this.userPhone,
    required this.dateText,                   // 예: 2025-11-11
    required this.timeText,                   // 예: 19시 36분-22시 36분
  });

  final String statusText;
  // final Color statusColor;
  final String userName;
  final String userPhone;
  final String dateText;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final statusColor = statusText == '예약 확정' ?  const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,             // ← 카드 배경 흰색 고정
      surfaceTintColor: Colors.white,  // ← M3 틴트 제거(완전 흰색 유지)
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 상태 칩
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
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
          ]),

          const SizedBox(height: 16),

          // 고객 정보 (같은 카드 내부, 흰 배경)
          _InfoBlock(
            icon: Icons.person_outline,
            title: '고객 정보',
            lines: [userName, userPhone], // 이름, 전화번호
          ),

          const SizedBox(height: 12),

          _InfoBlock(
            icon: Icons.access_time_rounded,
            title: '시간',
            lines: [dateText, timeText],   // 날짜, 시간
          ),
        ]),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Colors.black87),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: const TextStyle(fontSize: 14)),
            ),
        ]),
      ),
    ]);
  }
}
