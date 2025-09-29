import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Controller/community_controller.dart';
import '../../../Model/community_comment.dart';
import '../../../Util/Route/app_page.dart';
import '../../../Util/convert_time.dart';

Widget buildCommentTile(BuildContext context, CommunityController controller, CommunityComment comment, {bool isReply = false} ) {
  return Container(
    margin: EdgeInsets.only(
      left: isReply ? 40 : 0,  // 대댓글은 들여쓰기
      bottom: 8,
    ),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isReply ? Colors.grey[50] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 작성자 정보
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                (comment.authorName ?? '?')[0].toUpperCase(),
                style: TextStyle(color: Colors.blue[700], fontSize: 12),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName ?? '익명',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    TimeUtils.getTimeAgo(comment.createdAt.toString()),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            // 답글 버튼 (최상위 댓글에만 표시)
            if (!isReply)
              TextButton(
                onPressed: () {
                  controller.startReply(comment.commentId);
                },
                child: Text(
                  '답글',
                  style: TextStyle(color: Color(0xFF078714), fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        // 댓글 내용
        Text(
          comment.content ?? '',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    ),
  );
}
