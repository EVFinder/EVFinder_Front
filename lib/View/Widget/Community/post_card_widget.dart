import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Util/Route/app_page.dart';
import '../../../Util/convert_time.dart';

Widget buildPostCard(CommunityPost post, String cId) {
  return GestureDetector(
    onTap: () async{
      Get.toNamed(AppRoute.postdetail, arguments: {'pId': post.postId});
    },
    child: Card(
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
            trailing: Icon(Icons.more_vert),
          ),

          // 게시글 내용

          // 좋아요, 댓글, 공유 버튼
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.02),
            child: Row(
              children: [
                Text(post.authorName),
                Text(" · "),
                Text(TimeUtils.getTimeAgo(post.createdAt)),
                Text(" · "),
                Text('조회 ${post.views}'),
                Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.favorite_border, size: Get.size.width * 0.05),
                  label: Text(post.likes.toString()),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, size: Get.size.width * 0.05),
                  label: Text('${1 * 2 + 1}'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
