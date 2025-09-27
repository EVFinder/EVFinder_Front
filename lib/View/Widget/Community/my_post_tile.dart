import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Util/Route/app_page.dart';

Widget buildMyCommunityTile(BuildContext context, CommunityPost myPost) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(AppRoute.postdetail, arguments: {'pId': myPost.postId});
    },
    child: Card(
      margin: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04, vertical: Get.size.height * 0.005),
      child: ListTile(
        title: Text(myPost.title),
        subtitle: SizedBox(
          width: 150,
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text('위에서 관심있는 커뮤니티를 선택하면\n해당 커뮤니티의 게시글을 볼 수 있어요', style: TextStyle(overflow: TextOverflow.ellipsis)),
              Row(
                children: [
                  Icon(Icons.favorite_border, color: Color(0xFF078714)),
                  SizedBox(width: 5),
                  Text("2", style: TextStyle(color: Color(0xFF078714))),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: Get.size.width * 0.02),
            Icon(Icons.arrow_forward_ios, size: Get.size.width * 0.04),
          ],
        ),
        onTap: () {
          // 커뮤니티 상세 화면으로 이동
        },
      ),
    ),
  );
}
