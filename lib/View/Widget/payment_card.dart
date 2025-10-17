import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.title,       // 예: 'EVFinder'
    required this.createdAt,   // 결제/요청 시각
    required this.amount,      // 3000
    required this.status,      // 'SUCCESS' | 'CANCELLED'
    // this.onCancelTap,
  });

  final String title;
  final DateTime createdAt;
  final int amount;
  final String status;
  // final VoidCallback? onCancelTap;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'SUCCESS';

    final priceStyle = isSuccess
        ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
        : const TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDB2B2B),
      decoration: TextDecoration.lineThrough,
    );

    final chipBg    = isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final chipTxt   = isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final chipLabel = isSuccess ? '결제' : '취소';

    // final currency = NumberFormat('#,###', 'ko_KR');
    final dayStr   = DateFormat('M월 d일').format(createdAt);
    final timeStr  = DateFormat('HH:mm').format(createdAt);

    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9EDF2)),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x14000000), offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 아이콘 + 타이틀 + 상태칩
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chipBg,
                  ),
                  child: const Icon(Icons.flash_on, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(chipLabel, style: TextStyle(fontSize: 12, color: chipTxt, fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 날짜/시간
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Color(0xFF6B778C)),
                const SizedBox(width: 4),
                Text(dayStr, style: const TextStyle(color: Color(0xFF6B778C))),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: Color(0xFF6B778C)),
                const SizedBox(width: 4),
                Text(timeStr, style: const TextStyle(color: Color(0xFF6B778C))),
              ],
            ),

            const SizedBox(height: 12),

            // 금액
            Text('${amount}원', style: priceStyle),

            const SizedBox(height: 12),

            // // 하단 액션
            // if (isSuccess)
            //   SizedBox(
            //     width: double.infinity,
            //     child: OutlinedButton.icon(
            //       onPressed: onCancelTap,
            //       icon: const Icon(Icons.close, size: 16),
            //       label: const Text('취소하기'),
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: const Color(0xFFC62828),
            //         side: const BorderSide(color: Color(0xFFC62828)),
            //         padding: const EdgeInsets.symmetric(vertical: 12),
            //       ),
            //     ),
            //   )
            // else
            //   const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
