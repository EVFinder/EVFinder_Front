import 'package:evfinder_front/Controller/review_detail_controller.dart';
import 'package:evfinder_front/View/Widget/review_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReviewDetailView extends GetView<ReviewDetailController> {
  const ReviewDetailView({super.key});

  static String route = "/reviewDetail";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('리뷰 전체보기'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Obx(() => Row(
              children: [
                _buildSortButton(
                  text: '최신순',
                  isSelected: controller.sortOrder.value == 'latest',
                  onTap: () => controller.changeSortOrder('latest'),
                ),
                const SizedBox(width: 12),
                _buildSortButton(
                  text: '별점순',
                  isSelected: controller.sortOrder.value == 'rating',
                  onTap: () => controller.changeSortOrder('rating'),
                ),
              ],
            )),
          ),
          const Divider(height: 1),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.reviews.isEmpty) {
                return const Center(child: Text("작성된 리뷰가 없습니다."));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.reviews.length,
                itemBuilder: (context, index) {
                  final review = controller.reviews[index];
                  final String reviewUid = review['uid']?.toString() ?? '';
                  final bool isMine = controller.uid.value == reviewUid;
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

                  return ReviewCard(
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
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Get.theme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Get.theme.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}

