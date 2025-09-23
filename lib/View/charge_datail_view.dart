import 'package:evfinder_front/View/reserv_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ChargeDatailView extends StatelessWidget {
  const ChargeDatailView({super.key});
  static String route = "/detail";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          "우리은행본점",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Future.microtask(() {
                  Get.to(() => const ReservView());
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주소 + 거리
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '서울 강남구 강남대로 123',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.circle, size: 6, color: Color(0xFFCBD5E1)),
                SizedBox(width: 6),
                Text('0.5km 거리', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 12),

            // 칩들
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(text: '급속충전'),
                _Pill(text: '50kW'),
              ],
            ),
            const SizedBox(height: 12),

            const Text('운영시간: 24시간 운영', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 16),

            // 호스트 정보
            _SectionCard(
              title: '호스트 정보',
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('김충전', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        _HostRatingLine(ratingText: '4.8 (89개 리뷰)'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('연락처', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      SizedBox(height: 4),
                      Text('010-1234-5678', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 리뷰
            _SectionCard(
              title: '리뷰 (3)',
              child: Column(
                children: const [
                  _ReviewTile(
                    name: '박전기',
                    date: '2024년 1월 15일',
                    rating: 5,
                    text:
                    '위치가 정말 좋고 충전 속도도 빨라요. 근처에 카페도 있어서 충전하는 동안 시간 보내기 좋습니다.',
                  ),
                  SizedBox(height: 8),
                  _ReviewTile(
                    name: '이모빌리티',
                    date: '2024년 1월 10일',
                    rating: 4,
                    text: '깨끗하고 안전한 충전소입니다. 호스트분도 친절하시고 시설 관리가 잘 되어 있어요.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // 스크롤 하단 여백
          ],
        ),
      ),
    );
  }
}

/// ───── 작은 위젯들 ─────

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F7FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _HostRatingLine extends StatelessWidget {
  const _HostRatingLine({required this.ratingText});
  final String ratingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
        const SizedBox(width: 4),
        Text(ratingText, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
  });

  final String name;
  final String date;
  final int rating; // 0~5
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 2, color: Color(0x11000000), offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  // 별점
                  Row(
                    children: List.generate(
                      5,
                          (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 14,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 6),
              Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
            ]),
          ),
        ],
      ),
    );
  }
}
