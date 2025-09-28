import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Util/convert_time.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostDetailView extends GetView<CommunityController> {
  const PostDetailView({super.key});

  static String route = '/postdetail';

  @override
  Widget build(BuildContext context) {
    String postId = Get.arguments['pId'] ?? '';
    return FutureBuilder(
      future: controller.fetchPostDetail(controller.categoryId.value, postId),
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
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            body: Center(child: Text('오류가 발생했습니다.')),
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
                if (controller.postDetail.value!.owner == true)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'edit') {
                        print('게시글 수정');
                      } else if (value == 'delete') {
                        controller.showDeleteDialog();
                      }
                    },
                    itemBuilder: (context) => [PopupMenuItem(value: 'edit', child: Text('수정')), PopupMenuItem(value: 'delete', child: Text('삭제'))],
                  ),
              ],
            ),
            body: controller.postDetail.value == null
                ? Center(child: Text('게시글 정보가 없습니다.'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📝 제목
                          Row(
                            children: [
                              Text(
                                controller.postDetail.value!.title ?? '제목 없음',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                              ),
                              Spacer(),
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

                          // 💝 좋아요 버튼
                          // Container(
                          //   width: double.infinity,
                          //   child: ElevatedButton(
                          //     onPressed: () => _toggleLike(post),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: (post['liked'] == true) ? Colors.red[50] : Colors.grey[50],
                          //       foregroundColor: (post['liked'] == true) ? Colors.red : Colors.grey[700],
                          //       elevation: 0,
                          //       padding: EdgeInsets.symmetric(vertical: 16),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //         side: BorderSide(color: (post['liked'] == true) ? Colors.red[200]! : Colors.grey[300]!),
                          //       ),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Icon((post['liked'] == true) ? Icons.favorite : Icons.favorite_border, size: 20),
                          //         SizedBox(width: 8),
                          //         Text('좋아요 ${post['likes'] ?? 0}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Divider(thickness: 1),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '댓글',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text('asdf', style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6)),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        }
      },
    );
  }
}
