import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Util/Route/app_page.dart';
import '../../../Util/convert_time.dart';

Widget buildPostCard(CommunityPost post, String cId, bool isLike, CommunityController controller) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04, vertical: Get.size.height * 0.01),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04),
        //   child: Text(post.title, style: TextStyle(fontSize: Get.size.width * 0.035)),
        // ),
        // 게시글 헤더
        ListTile(
          title: Row(
            children: [
              Text(
                post.title,
                style: TextStyle(fontSize: Get.size.width * 0.035, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: Get.size.width * 0.02),
            ],
          ),
          // trailing: Icon(Icons.more_vert),
        ),

        // 게시글 내용

        // 좋아요, 댓글, 공유 버튼
        Padding(
          padding: EdgeInsets.all(Get.size.width * 0.03),
          child: Row(
            children: [
              Text(post.authorName),
              Text(" · "),
              Text(TimeUtils.getTimeAgo(post.createdAt)),
              Text(" · "),
              Text('조회 ${post.views}'),
              Spacer(),
              Icon(isLike ? Icons.favorite : Icons.favorite_border, size: Get.size.width * 0.06, color: Color(0xFF078714)),
              SizedBox(width: Get.size.width * 0.02),
              Text(post.likes.toString(), style: TextStyle(color: Color(0xFF078714))),
              SizedBox(width: Get.size.width * 0.03),
              Icon(Icons.comment_outlined, size: Get.size.width * 0.06, color: Color(0xFF078714)),
              SizedBox(width: Get.size.width * 0.02),
              FutureBuilder<int>(
                future: controller.getCommentCount(cId, post.postId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('${snapshot.data}', style: TextStyle(color: Color(0xFF078714)));
                  } else {
                    return Text('0', style: TextStyle(color: Color(0xFF078714)));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
