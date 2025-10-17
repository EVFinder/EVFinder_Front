import 'package:evfinder_front/Controller/charge_detail_controller.dart';
import 'package:evfinder_front/Controller/reserv_controller.dart';
import 'package:evfinder_front/Controller/review_write_controller.dart';
import 'package:evfinder_front/View/Widget/host_card.dart';
import 'package:evfinder_front/View/Widget/review_card.dart';
import 'package:evfinder_front/View/reserv_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ChargeDetailView extends GetView<ChargeDetailController> {
  const ChargeDetailView({super.key});

  static String route = "/detail";

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final station = args['station'] as Map<String, dynamic>;
    final ownerUid = station['ownerUid']?.toString();
    final shareId = station['id']?.toString();
    // print('$station');
    // print('station uid : $ownerUid');
    // print('컨트롤러 uid :${controller.uid.value}');
    final accentColor = const Color(0xFF10B981);
    DateTime? selectedDate;

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
                  onPressed: () async {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: [
                            Icon(Icons.settings, color: accentColor, size: 24),
                            const SizedBox(width: 8),
                            const Text('충전소 상태 변경', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        content: const Text('충전소의 상태를 선택해주세요.', style: TextStyle(color: Color(0xFF6B7280))),
                        actions: [
                          Container(
                            decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                            child: TextButton(
                              onPressed: () async {
                                Get.dialog(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: accentColor, size: 24),
                                        const SizedBox(width: 8),
                                        const Text("활성화 관리", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    content: Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Obx(
                                            () => Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: TableCalendar<dynamic>(
                                                firstDay: DateTime.utc(2010, 10, 16),
                                                lastDay: DateTime.utc(2030, 3, 14),
                                                focusedDay: controller.focusedDay.value,
                                                calendarFormat: CalendarFormat.month,
                                                headerStyle: HeaderStyle(
                                                  formatButtonVisible: false,
                                                  titleCentered: true,
                                                  titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                                                  leftChevronIcon: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.chevron_left, color: Color(0xFF374151)),
                                                  ),
                                                  rightChevronIcon: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.chevron_right, color: Color(0xFF374151)),
                                                  ),
                                                ),
                                                calendarStyle: CalendarStyle(
                                                  outsideDaysVisible: false,
                                                  selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  // 범위 하이라이트
                                                  rangeHighlightColor: accentColor.withOpacity(0.2),
                                                  rangeStartDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  rangeEndDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  withinRangeDecoration: BoxDecoration(color: accentColor.withOpacity(0.1)),
                                                  todayDecoration: BoxDecoration(
                                                    color: accentColor.withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: accentColor, width: 2),
                                                  ),
                                                  disabledDecoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                                  disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                                                ),
                                                enabledDayPredicate: (day) {
                                                  return controller.isDayDisabled(day);
                                                },
                                                onDaySelected: (selectedDay, focusedDay) {
                                                  if (!controller.isDayDisabled(selectedDay)) return;

                                                  if (controller.selectedStartDate.value == null) {
                                                    // 첫 번째 클릭: 시작일 설정
                                                    controller.selectStartDate(selectedDay);
                                                  } else if (controller.selectedEndDate.value == null) {
                                                    // 두 번째 클릭: 종료일 설정
                                                    if (selectedDay.isAfter(controller.selectedStartDate.value!)) {
                                                      controller.selectEndDate(selectedDay);
                                                    } else {
                                                      // 시작일보다 이전 날짜를 선택한 경우, 새로운 시작일로 설정
                                                      controller.clearDateRange();
                                                      controller.selectStartDate(selectedDay);
                                                    }
                                                  } else {
                                                    // 이미 범위가 선택된 상태: 새로운 시작일로 초기화
                                                    controller.clearDateRange();
                                                    controller.selectStartDate(selectedDay);
                                                  }

                                                  controller.focusedDay.value = focusedDay;
                                                },
                                                // 범위 표시
                                                rangeStartDay: controller.selectedStartDate.value,
                                                rangeEndDay: controller.selectedEndDate.value,
                                                selectedDayPredicate: (day) {
                                                  return false; // 개별 선택 표시 비활성화 (범위 표시 사용)
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Container(
                                        decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
                                        child: TextButton(
                                          onPressed: () async {
                                            if (controller.selectedStartDate.value != null) {
                                              // 선택된 날짜로 다음 단계 진행
                                              if (ownerUid != null && shareId != null) {
                                                print(controller.getSelectedDateRange());
                                                bool success = await controller.deleteDisabledDates(ownerUid, shareId, controller.getSelectedDateRange());
                                                if (success) {
                                                  Get.back();
                                                  Get.back();
                                                  controller.clearDateRange();
                                                  controller.fetchReserveDate(ownerUid, shareId);
                                                  Get.snackbar('성공', '활성화 되었습니다.');
                                                } else {
                                                  Get.snackbar('오류', '날짜 설정에 실패했습니다. 다시 시도해주세요.');
                                                }
                                              }
                                            } else {
                                              Get.snackbar('알림', '날짜를 선택해주세요.');
                                            }
                                          },
                                          child: const Text(
                                            '활성화',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.clearDateRange();
                                        },
                                        child: const Text(
                                          '취소',
                                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                '활성화',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                            child: TextButton(
                              onPressed: () async {
                                Get.dialog(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(
                                      children: [
                                        const Icon(Icons.block, color: Colors.red, size: 24),
                                        const SizedBox(width: 8),
                                        const Text("비활성화 날짜 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    content: Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Obx(
                                            () => Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: TableCalendar<dynamic>(
                                                firstDay: DateTime.utc(2010, 10, 16),
                                                lastDay: DateTime.utc(2030, 3, 14),
                                                focusedDay: controller.focusedDay.value,
                                                calendarFormat: CalendarFormat.month,
                                                headerStyle: HeaderStyle(
                                                  formatButtonVisible: false,
                                                  titleCentered: true,
                                                  titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                                                  leftChevronIcon: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.chevron_left, color: Color(0xFF374151)),
                                                  ),
                                                  rightChevronIcon: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.chevron_right, color: Color(0xFF374151)),
                                                  ),
                                                ),
                                                calendarStyle: CalendarStyle(
                                                  outsideDaysVisible: false,
                                                  selectedDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  // 범위 하이라이트
                                                  rangeHighlightColor: accentColor.withOpacity(0.2),
                                                  rangeStartDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  rangeEndDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                                  withinRangeDecoration: BoxDecoration(color: accentColor.withOpacity(0.1)),
                                                  todayDecoration: BoxDecoration(
                                                    color: accentColor.withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: accentColor, width: 2),
                                                  ),
                                                  disabledDecoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                                  disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                                                ),
                                                enabledDayPredicate: (day) {
                                                  return !controller.isDayDisabled(day);
                                                },
                                                onDaySelected: (selectedDay, focusedDay) {
                                                  if (controller.isDayDisabled(selectedDay)) return;

                                                  if (controller.selectedStartDate.value == null) {
                                                    // 첫 번째 클릭: 시작일 설정
                                                    controller.selectStartDate(selectedDay);
                                                  } else if (controller.selectedEndDate.value == null) {
                                                    // 두 번째 클릭: 종료일 설정
                                                    if (selectedDay.isAfter(controller.selectedStartDate.value!)) {
                                                      controller.selectEndDate(selectedDay);
                                                    } else {
                                                      // 시작일보다 이전 날짜를 선택한 경우, 새로운 시작일로 설정
                                                      controller.clearDateRange();
                                                      controller.selectStartDate(selectedDay);
                                                    }
                                                  } else {
                                                    // 이미 범위가 선택된 상태: 새로운 시작일로 초기화
                                                    controller.clearDateRange();
                                                    controller.selectStartDate(selectedDay);
                                                  }

                                                  controller.focusedDay.value = focusedDay;
                                                },
                                                // 범위 표시
                                                rangeStartDay: controller.selectedStartDate.value,
                                                rangeEndDay: controller.selectedEndDate.value,
                                                selectedDayPredicate: (day) {
                                                  return false; // 개별 선택 표시 비활성화 (범위 표시 사용)
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.red.shade200),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.info, color: Colors.red, size: 16),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "과거의 날짜는 비활성화가 불가능합니다.",
                                                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Container(
                                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                        child: TextButton(
                                          onPressed: () async {
                                            if (controller.selectedStartDate.value != null) {
                                              // 선택된 날짜로 다음 단계 진행
                                              if (ownerUid != null && shareId != null) {
                                                print(controller.getSelectedDateRange());
                                                bool success = await controller.addDisabledDates(ownerUid, shareId, controller.getSelectedDateRange());
                                                if (success) {
                                                  Get.back();
                                                  Get.back();
                                                  controller.clearDateRange();
                                                  controller.fetchReserveDate(ownerUid, shareId);
                                                  Get.snackbar('성공', '해당 날짜가 비활성화 되었습니다.');
                                                } else {
                                                  Get.snackbar('오류', '날짜 설정에 실패했습니다. 다시 시도해주세요.');
                                                }
                                              }
                                              // _proceedWithReservation(controller.selectedStartDate.value!);
                                            } else {
                                              Get.snackbar('알림', '날짜를 선택해주세요.');
                                            }
                                          },
                                          child: const Text(
                                            '비활성화',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.clearDateRange();
                                        },
                                        child: const Text(
                                          '취소',
                                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                '비활성화',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
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
                  child: const Text('비활성화/활성화'),
                ),

                // 예약 진행 함수 (별도로 구현 필요)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('예약자 조회', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        Get.toNamed('/reserv', arguments: {'station': station});
                        ReservController recontroller = Get.find<ReservController>();
                        recontroller.selectMode(); //selectMode 실행
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
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

            Obx(
              () => _SectionCard(
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Row(
                                  children: [
                                    const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                    const SizedBox(width: 8),
                                    const Text('리뷰 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                content: const Text('정말로 이 리뷰를 삭제하시겠습니까?', style: TextStyle(color: Color(0xFF6B7280))),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                    child: TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteReview(reviewId);
                                      },
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onEdit: () {
                            Get.toNamed("/reviewWrite", arguments: {'review': review});
                            ReviewWriteController reviewcontroller = Get.find<ReviewWriteController>();
                            reviewcontroller.handleArguments();
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
                              Get.toNamed("reviewDetail", arguments: station);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF374151),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
