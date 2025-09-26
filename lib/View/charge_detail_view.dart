import 'package:evfinder_front/View/Widget/host_card.dart';
import 'package:evfinder_front/View/Widget/review_card.dart';
import 'package:evfinder_front/View/reserv_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ChargeDetailView extends StatelessWidget {
  const ChargeDetailView({super.key});

  static String route = "/detail";

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final station = args['station'] as Map<String, dynamic>;
    final isHost = args['isHost'] as bool;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(station['stationName'], style: TextStyle(fontWeight: FontWeight.w700)),
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: !isHost
                ? ElevatedButton(
                    onPressed: () {
                      print("전달 데이터 : $station");
                      Get.toNamed('/reserv', arguments: station);
                    },
                    // {
                    //   Future.microtask(() {
                    //     Get.to(() => const ReservView());
                    //   });
                    // },
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('예약하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  )
                : SizedBox.shrink(),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주소
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    station['address'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.circle, size: 6, color: Color(0xFFCBD5E1)),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 12),

            // 칩들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(text: station['chargerType']),
                _Pill(text: station['power']),
              ],
            ),
            const SizedBox(height: 12),

            // 호스트 정보
            _SectionCard(
              title: '호스트 정보',
              child: HostCard(hostName: station['hostName'], hostContact: station['hostContact']),
            ),
            const SizedBox(height: 16),

            // 리뷰
            _SectionCard(
              title: '리뷰 (3)',
              child: ReviewCard(userName: '길동홍', rating: 3, content: '조음', createdAt: '2021-08-23'),
            ),

            const SizedBox(height: 80), // 스크롤 하단 여백
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
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
      color: const Color(0xFFf2f2f2),
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
