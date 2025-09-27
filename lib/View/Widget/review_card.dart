import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.isMine = false,
    this.onEdit,
    this.onDelete,
  });

  final String userName;
  final int rating;
  final String content;
  final String createdAt;
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 프로필 아이콘, 이름, 날짜, 메뉴 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.person, size: 22, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              if (isMine)
                _buildPopupMenu(),
            ],
          ),
          const SizedBox(height: 12),

          // 중간: 별점
          Stars(rating: rating),
          const SizedBox(height: 10),

          // 하단: 리뷰 내용
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
          ),
        ],
      ),
    );
  }

  // 3. PopupMenuButton을 만드는 별도의 함수입니다.
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call(); // onEdit 콜백 실행
        } else if (value == 'delete') {
          onDelete?.call(); // onDelete 콜백 실행
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('수정'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('삭제'),
        ),
      ],
      icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
      padding: EdgeInsets.zero,
    );
  }
}

class Stars extends StatelessWidget {
  const Stars({super.key, required this.rating});
  final int rating; // 1~5

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: const Color(0xFFFBBF24),
        ),
      ),
    );
  }
}

