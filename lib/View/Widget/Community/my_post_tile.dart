import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Util/Route/app_page.dart';

Widget buildMyCommunityTile(BuildContext context, CommunityPost myPost, bool isLike, CommunityController controller) {
  return Card(
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
                Icon(isLike ? Icons.favorite : Icons.favorite_border, size: Get.size.width * 0.06, color: Color(0xFF078714)),
                SizedBox(width: Get.size.width * 0.02),
                Text("${myPost.likes}", style: TextStyle(color: Color(0xFF078714))), // 하드코딩된 "2"를 실제 likes 값으로 변경
                SizedBox(width: Get.size.width * 0.03),
                Icon(Icons.comment_outlined, size: Get.size.width * 0.06, color: Color(0xFF078714)),
                SizedBox(width: Get.size.width * 0.02),
                FutureBuilder<int>(
                  future: controller.getCommentCount(myPost.categoryId, myPost.postId), // myPost에는 categoryId가 있음
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
    ),
  );
}
