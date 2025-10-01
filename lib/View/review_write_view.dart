import 'package:evfinder_front/Controller/review_write_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReviewWriteView extends GetView<ReviewWriteController> {
  const ReviewWriteView({super.key});

  static String route = "/reviewWrite";

  @override
  Widget build(BuildContext context) {
    const panelBg = Color(0xFFF7F9FC);
    const unselectedStar = Color(0xFFD1D5DB);

    return Scaffold(
      backgroundColor: panelBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('리뷰 작성'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),

      // 하단 '등록하기' 버튼 (기능 동일)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: () => controller.Review(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              // minimumSize: const Size(double.infinity, 52),
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('등록하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ),

      // 본문 (디자인만 변경)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀
                    const Center(
                      child: Text('이용 경험은 어떠셨나요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 14),

                    // 별점 (기능 동일)
                    Center(
                      child: Obx(
                        () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final filled = index < controller.rating.value;
                            return IconButton(
                              splashRadius: 22,
                              onPressed: () => controller.setRating(index + 1),
                              icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded, size: 40, color: filled ? Colors.amber : unselectedStar),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 라벨
                    const Text('상세한 리뷰를 남겨주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    // 내용 입력 (스타일만 개선)
                    TextField(
                      controller: controller.contentController,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: '충전소 이용 경험에 대해 자세히 알려주세요.\n(주차 편의성, 충전기 상태, 주변 환경 등)',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.4),
                        ),
                        counterStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
