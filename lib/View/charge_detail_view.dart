import 'package:evfinder_front/Controller/charge_detail_controller.dart';
import 'package:evfinder_front/View/Widget/host_card.dart';
import 'package:evfinder_front/View/Widget/review_card.dart';
import 'package:evfinder_front/View/reserv_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class ChargeDetailView extends GetView<ChargeDetailController> {
  const ChargeDetailView({super.key});

  static String route = "/detail";

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final station = args['station'] as Map<String, dynamic>;
    final ownerUid = station['ownerUid']?.toString();
    print('$station');
    print('station uid : $ownerUid');
    print('컨트롤러 uid :${controller.uid.value}');

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                station['stationName'],
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // isHost가 true일 때만 버튼을 보여줍니다.

            Obx(() {
              final isOwner = controller.uid.value == ownerUid;
              if (!isOwner) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('충전소 상태 변경'),
                        content: const Text('충전소의 상태를 선택해주세요.'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              final ok = await controller.statChange(station['id'], "available");
                              if (ok) { Get.back(); Get.back(result: true); }
                            },
                            child: const Text('사용 가능'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final ok = await controller.statChange(station['id'], "unavailable");
                              if (ok) { Get.back(); Get.back(result: true); }
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
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('상태 변경'),
                ),
              );
            }),
          ],
        ),
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(() {
            final isOwner = controller.uid.value == ownerUid;
            return SizedBox(
              height: 52,
              width: double.infinity,
              child: isOwner
                  ? ElevatedButton(
                onPressed: () => Get.toNamed('/management', arguments: station),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('예약자 조회', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              )
                  : ElevatedButton(
                onPressed: () => Get.toNamed('/reserv', arguments: station),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('예약하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            );
          }),
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
            // _SectionCard(
            //   title: '리뷰 (3)',
            //   child: ReviewCard(userName: '길동홍', rating: 3, content: '조음', createdAt: '2021-08-23'),
            //
            // ),

            Obx(() => _SectionCard(
            // title: '리뷰 (${controller.bnbReview.length})',
              title: '리뷰',
              child: Column(
                children: [
                  if (controller.isLoading.value)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.bnbReview.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: Text('작성된 리뷰가 없습니다.')),
                    ),

                  ...controller.bnbReview.map((review) {

                    final String reviewAuthorUid = review['uid']?.toString() ?? '';


                    final bool isMine = controller.uid.value == reviewAuthorUid;
                    final String reviewId = review['reviewId'] as String;
                    final String create = review['createdAt'] as String;
                    String dateText = '-';

                    try {
                      final createDate = DateTime.parse(create);
                      dateText = DateFormat('yyyy-MM-dd').format(createDate);
                    } catch (e) {
                      print("날짜 파싱 에러: $create, 오류: $e");
                      dateText = create;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ReviewCard(
                        userName: review['userName'] as String,
                        rating: review['rating'] as int,
                        content: review['content'] as String,
                        createdAt: dateText,
                        isMine: isMine,
                        onDelete: () {
                          Get.dialog(
                              AlertDialog(
                                  title: const Text('리뷰 삭제'),
                                  content: const Text('정말로 이 리뷰를 삭제하시겠습니까?'),
                                  actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('취소'),
                                  ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteReview(reviewId);
                                      },
                                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                              ),
                          );
                        },
                        onEdit: () {
                          Get.toNamed("/reviewWrite", arguments: {'review': review});
                        },
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed("/reviewWrite", arguments: {'station': station});
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF374151),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('리뷰 작성'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed("reviewDetail", arguments: station);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF374151),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('더 보기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                  ),
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
      color: Colors.white,
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
