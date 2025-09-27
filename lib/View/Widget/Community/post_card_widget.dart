import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

Widget buildPostCard(int index) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04, vertical: Get.size.height * 0.01),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 게시글 헤더
        ListTile(
          title: Row(
            children: [
              Text('사용자 ${index + 1}'),
              SizedBox(width: Get.size.width * 0.02),
            ],
          ),
          subtitle: Text('${index + 1}시간 전'),
          trailing: Icon(Icons.more_vert),
        ),
        // 게시글 내용
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04),
          child: Text('커뮤니티에서 공유하고 싶은 내용입니다. 여러분의 의견을 듣고 싶어요! #커뮤니티 #소통', style: TextStyle(fontSize: Get.size.width * 0.035)),
        ),
        SizedBox(height: Get.size.height * 0.015),
        SizedBox(height: Get.size.height * 0.015),
        // 좋아요, 댓글, 공유 버튼
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.02),
          child: Row(
            children: [
              TextButton.icon(
                icon: Icon(Icons.favorite_border, size: Get.size.width * 0.05),
                label: Text('${index * 3 + 5}'),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: Icon(Icons.comment_outlined, size: Get.size.width * 0.05),
                label: Text('${index * 2 + 1}'),
                onPressed: () {},
              ),
              Spacer(),
              TextButton.icon(
                icon: Icon(Icons.visibility, size: Get.size.width * 0.05),
                label: Text('${index * 2 + 1}'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
