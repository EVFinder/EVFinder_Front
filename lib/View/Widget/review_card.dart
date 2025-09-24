import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
});
  final String userName;
  final int rating;
  final String content;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 작성자 / 별점 / 날짜
                Row(
                  children: [
                    Expanded(
                      child: Text(userName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Stars(rating: rating),
                    const SizedBox(width: 8),
                    Text(createdAt, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
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
            (i) => const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B))
            .copyWith(icon: i < rating ? Icons.star : Icons.star_border),
      ),
    );
  }
}

extension on Icon {
  Icon copyWith({IconData? icon}) =>
      Icon(icon ?? this.icon, size: size, color: color);
}