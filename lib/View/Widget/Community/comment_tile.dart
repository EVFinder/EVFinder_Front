import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../Util/Route/app_page.dart';

Widget buildCommentTile(BuildContext context) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    "sd",
                    // (controller.postDetail.value!.authorName ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "익명",
                        // controller.postDetail.value!.authorName ?? '익명',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      // Text(TimeUtils.getTimeAgo(controller.postDetail.value!.createdAt), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.size.height * 0.01),
            Padding(
              padding: EdgeInsets.only(left: Get.size.width * 0.02),
              child: Text('아니 근데 내생각엔 그건 아닌거 같은데', style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6)),
            ),
          ],
        ),
      ),
      SizedBox(height: Get.size.height * 0.02),
    ],
  );
}
