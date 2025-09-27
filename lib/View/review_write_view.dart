import 'package:evfinder_front/Controller/review_write_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReviewWriteView extends GetView<ReviewWriteController> {
  const ReviewWriteView({super.key});

  static String route = "/reviewWrite";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
      ),
      // 하단 '등록하기' 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: () {
              controller.Review(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('등록하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      // 본문 내용 (스크롤 가능)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 별점 섹션
            const Text(
              '이용 경험은 어떠셨나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => controller.setRating(index + 1),
                    icon: Icon(
                      index < controller.rating.value ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              )),
            ),
            const SizedBox(height: 24),

            // 리뷰 내용 입력 섹션
            const Text(
              '상세한 리뷰를 남겨주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.contentController,
              maxLines: 8,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '충전소 이용 경험에 대해 자세히 알려주세요.\n(주차 편의성, 충전기 상태, 주변 환경 등)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
