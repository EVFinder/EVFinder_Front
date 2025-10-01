import 'package:flutter/material.dart';

class ReservUserCard extends StatelessWidget {
  const ReservUserCard({
    super.key,
    required this.stationName,
    required this.address,
    required this.rating,          // 별점 4.9
    required this.statusText,      // 예: 예약 확정
    required this.dateText,        // 예: 2025. 09. 26.
    required this.timeText,        // 예: 19시 31분 - 23시 31분
    this.onCancel,
    this.onUpdate,
  });

  final String stationName;
  final String address;
  final double rating;
  final String statusText;
  final String dateText;
  final String timeText;
  final VoidCallback? onCancel;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final statusColor = statusText == '예약 확정' ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    const textDark = Color(0xFF0F172A);
    const textSub = Color(0xFF64748B);
    const star = Color(0xFFF59E0B);
    const panelBg = Color(0xFFF7F9FC);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 16, offset: const Offset(0, 6))],
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              stationName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textDark),
            ),
            const SizedBox(height: 8),

            // 주소
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: textSub),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: textSub, height: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 별점 + 상태칩
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 18, color: star),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textDark),
                ),
                const SizedBox(width: 12),
                _StatusChip(text: statusText, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),

            // 회색 패널(이용일/시간)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(color: panelBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이용일
                  Row(
                    children: const [
                      Icon(Icons.calendar_month_rounded, color: Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Text('이용일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(dateText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 16),

                  // 시간
                  Row(
                    children: const [
                      Icon(Icons.access_time_rounded, color: Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Text('시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(timeText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 버튼들
            // onUpdate != null || onCancel != null
            //     ? Row(
            //         children: [
            //           // 예약 수정(그린 아웃라인)
            //           Expanded(
            //             child: OutlinedButton.icon(
            //               onPressed: onUpdate,
            //               icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF10B981)),
            //               label: const Text(
            //                 '예약 수정',
            //                 style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
            //               ),
            //               style: OutlinedButton.styleFrom(
            //                 side: const BorderSide(color: Color(0xFF10B981)),
            //                 padding: const EdgeInsets.symmetric(vertical: 14),
            //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(width: 12),
            //           // 취소(레드 아웃라인)
            //           Expanded(
            //             child: OutlinedButton.icon(
            //               onPressed: onCancel,
            //               icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFEF4444)),
            //               label: const Text(
            //                 '취소',
            //                 style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
            //               ),
            //               style: OutlinedButton.styleFrom(
            //                 side: const BorderSide(color: Color(0xFFEF4444)),
            //                 padding: const EdgeInsets.symmetric(vertical: 14),
            //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            //                 foregroundColor: const Color(0xFFEF4444),
            //               ),
            //             ),
            //           ),
            //         ],
            //       )
            //     : Row(
            //         children: [
            //           Expanded(
            //             child: OutlinedButton.icon(
            //               onPressed: () {
            //                 Get.toNamed("/reviewWrite");
            //               },
            //               icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF425df5)),
            //               label: const Text(
            //                 '리뷰 작성',
            //                 style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF425df5)),
            //               ),
            //               style: OutlinedButton.styleFrom(
            //                 side: const BorderSide(color: Color(0xFF425df5)),
            //                 padding: const EdgeInsets.symmetric(vertical: 14),
            //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            Row(
              children: [
                // 예약 수정(그린 아웃라인)
                if (onUpdate != null || onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUpdate,
                      icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF10B981)),
                      label: const Text(
                        '예약 수정',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // 취소(레드 아웃라인)
                if (onUpdate != null || onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFEF4444)),
                      label: const Text(
                        '취소',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        foregroundColor: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .2),
      ),
    );
  }
}
