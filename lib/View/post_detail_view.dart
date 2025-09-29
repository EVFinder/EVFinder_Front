import 'dart:io';

import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Util/convert_time.dart';
import 'package:evfinder_front/View/Widget/Community/comment_tile.dart';
import 'package:evfinder_front/View/Widget/Community/popup_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Util/Route/app_page.dart';

class PostDetailView extends GetView<CommunityController> {
  const PostDetailView({super.key});

  static String route = '/postdetail';

  @override
  Widget build(BuildContext context) {
    // null 체크 추가
    final arguments = Get.arguments as Map<String, dynamic>?;
    final String postId = arguments?['pId'] ?? '';
    final String? categoryIdFromArgs = arguments?['cId'];
    final RxBool isLike = (arguments?['isLike'] ?? false);
    TextEditingController commentController = TextEditingController();

    // categoryId 결정: arguments에서 온 cId가 있으면 사용, 없으면 controller의 categoryId 사용
    final String categoryId = categoryIdFromArgs?.isNotEmpty == true ? categoryIdFromArgs! : controller.categoryId.value;

    // postId가 비어있으면 오류 화면 표시
    if (postId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Text('오류', style: TextStyle(color: Colors.black87)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('게시글 정보가 없습니다.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ElevatedButton(onPressed: () => Get.back(), child: Text('돌아가기')),
            ],
          ),
        ),
      );
    }

    return FutureBuilder(
      // categoryId 변수 사용
      future: controller.fetchPostDetail(categoryId, postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('오류가 발생했습니다.', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('${snapshot.error}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Get.back(), child: Text('돌아가기')),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Obx(() {
                    return IconButton(
                      icon: Icon(isLike.value ? Icons.favorite : Icons.favorite_border, size: Get.size.width * 0.06, color: Color(0xFF078714)),
                      onPressed: () {
                        try {
                          if (isLike.value) {
                            controller.updateLike("remove", categoryId, postId);
                          } else {
                            controller.updateLike("add", categoryId, postId);
                          }
                          isLike.value = !isLike.value;
                          print(isLike.value);
                        } catch (e) {
                          print('좋아요 처리 중 오류 발생: $e');
                        }
                      },
                    );
                  }),
                ),
                if (controller.postDetail.value?.owner == true)
                  popupMenuButton(
                    () {
                      Get.toNamed(AppRoute.editpost);
                    },
                    () {
                      controller.deletePost(categoryId, controller.postDetail.value!.postId);
                    },
                    controller.postDetail.value!.title,
                    false,
                  ),
              ],
            ),
            body: controller.postDetail.value == null
                ? Center(child: Text('게시글 정보가 없습니다.'))
                : Obx(() {
                    return Column(
                      children: [
                        // 상단 내용 (스크롤 가능)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 📝 제목
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          controller.postDetail.value!.title ?? '제목 없음',
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                                        ),
                                      ),
                                      Text("좋아요: ${controller.postDetail.value!.likes}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      SizedBox(width: Get.size.width * 0.02),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                                            SizedBox(width: 4),
                                            Text('${controller.postDetail.value!.views ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  // 👤 작성자 정보
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue[100],
                                          child: Text(
                                            (controller.postDetail.value!.authorName ?? '?')[0].toUpperCase(),
                                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.postDetail.value!.authorName ?? '익명',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                              Text(TimeUtils.getTimeAgo(controller.postDetail.value!.createdAt), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  // 📄 내용
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Text(controller.postDetail.value!.content ?? '내용이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6)),
                                  ),
                                  SizedBox(height: 24),
                                  Divider(thickness: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '댓글',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  ...List.generate(10, (index) => buildCommentTile(context)),

                                  SizedBox(height: 16), // 마지막 여백
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 하단 댓글 입력창 (고정)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: SafeArea(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: commentController,
                                    decoration: InputDecoration(
                                      hintText: '댓글을 입력하세요...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    controller.createComment(categoryId, postId, commentController.text, null);
                                    commentController.clear();
                                  },
                                  icon: Icon(Icons.send, color: Color(0xFF078714)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
          );
        }
      },
    );
  }
}
