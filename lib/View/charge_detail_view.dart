import 'package:evfinder_front/Controller/charge_detail_controller.dart';
import 'package:evfinder_front/View/Widget/host_card.dart';
import 'package:evfinder_front/View/Widget/review_card.dart';
import 'package:evfinder_front/View/reserv_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ChargeDetailView extends GetView<ChargeDetailController> {
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 기존 타이틀은 Expanded로 감싸서 긴 이름도 잘리지 않게 처리
            Expanded(
              child: Text(
                station['stationName'],
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // isHost가 true일 때만 버튼을 보여줍니다.
            if (isHost)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('충전소 상태 변경'),
                        content: const Text('충전소의 상태를 선택해주세요.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              controller.statChange(station['id'], "available");
                              Get.toNamed("/main");
                            },
                            child: const Text('사용 가능'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.statChange(station['id'], "unavailable");
                              Get.toNamed("/main");
                            },
                            child: const Text('불가능'),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('취소', style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade800,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  child: const Text('상태 변경'),
                ),
              ),
          ],
        ),
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: isHost
                ? ElevatedButton(
              onPressed: () {
                print("호스트 전달 데이터; $station");
                Get.toNamed('/management', arguments: station);
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('예약자 조회', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            )
                : ElevatedButton(
              onPressed: () {
                Get.toNamed('/reserv', arguments: station);
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('예약하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
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
