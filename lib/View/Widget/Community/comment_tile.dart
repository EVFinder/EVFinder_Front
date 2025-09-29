import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Controller/community_controller.dart';
import '../../../Model/community_comment.dart';
import '../../../Util/Route/app_page.dart';
import '../../../Util/convert_time.dart';

Widget buildCommentTile(BuildContext context, CommunityController controller, CommunityComment comment, {bool isReply = false}) {
  return Obx(() {
    final isEditing = controller.isEditingComment(comment.commentId);

    return Container(
      margin: EdgeInsets.only(left: isReply ? 40 : 0, bottom: 8),
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
                child: Text((comment.authorName ?? '?')[0].toUpperCase(), style: TextStyle(color: Colors.blue[700], fontSize: 12)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.authorName ?? '익명', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(TimeUtils.getTimeAgo(comment.createdAt.toString()), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),

              // 수정/삭제 버튼 (본인 댓글만)
              if (comment.owner && !isEditing) ...[
                _buildActionButton('수정', () => controller.startEditComment(comment.commentId, comment.content ?? '')),
                _buildActionButton('삭제', () => controller.deleteComment(comment.commentId)),
              ],

              // 수정 모드 버튼들
              if (comment.owner && isEditing) ...[
                _buildActionButton('완료', () => controller.updateComment(comment.commentId)),
                _buildActionButton('취소', () => controller.cancelEditComment(comment.commentId)),
              ],

              // 답글 버튼 (최상위 댓글에만, 수정 모드가 아닐 때만)
              if (!isReply && !isEditing) _buildActionButton('답글', () => controller.startReply(comment.commentId)),
            ],
          ),
          SizedBox(height: 8),

          // 댓글 내용 (수정 모드에 따라 다르게 표시)
          if (isEditing)
            Column(
              children: [
                TextField(
                  controller: controller.editControllers[comment.commentId],
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: '댓글을 수정하세요...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 8),
              ],
            )
          else
            Text(comment.content ?? '', style: TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  });
}

// 액션 버튼 위젯
Widget _buildActionButton(String text, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    child: Text(
      text,
      style: TextStyle(color: Color(0xFF078714), fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );
}
