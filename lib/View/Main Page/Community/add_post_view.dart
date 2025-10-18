import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Controller/MainPage/Community/community_controller.dart';
import '../../../Util/Route/app_page.dart';

class AddPostView extends GetView<CommunityController> {
  const AddPostView({super.key});

  static String route = '/addpost';

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    // ✅ 카테고리 로드
    // controller.fetchCategories();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '게시글 작성',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.selectedCategory.value == null) {
                Get.snackbar('알림', '카테고리를 선택해주세요.');
                return;
              }

              if (titleController.text.trim().isEmpty) {
                Get.snackbar('알림', '제목을 입력해주세요.');
                return;
              }
              if (contentController.text.trim().isEmpty) {
                Get.snackbar('알림', '내용을 입력해주세요.');
                return;
              }

              String cId = controller.selectedCategory.value!.categoryId;

              // ✅ 로딩 표시
              Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

              try {
                bool isCreated = await controller.createPost(cId, titleController.text.trim(), contentController.text.trim());

                // ✅ 로딩 닫기
                Get.back();

                if (isCreated) {
                  await controller.fetchPost(cId);
                  Get.snackbar('성공', '게시글이 작성되었습니다.');
                  controller.clearSelectedCategory();
                  titleController.clear();
                  contentController.clear();
                  Get.offAndToNamed(AppRoute.main);
                } else {
                  Get.snackbar('오류', '게시글 작성에 실패했습니다.');
                }
              } catch (e) {
                // ✅ 로딩 닫기
                Get.back();
                Get.snackbar('오류', '네트워크 오류가 발생했습니다.');
              }
            },
            child: Text(
              '완료',
              style: TextStyle(color: Color(0xFF078714), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // ✅ 카테고리 선택 추가
              _buildCategorySelector(),
              SizedBox(height: 16),

              // 📝 제목 입력
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: titleController,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '제목을 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 20, fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),

              SizedBox(height: 16),

              // 👤 작성자 정보 (현재 사용자)
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
                        controller.prefs.getString('name')!.substring(0, 1), // 현재 사용자 이름 첫 글자
                        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.prefs.getString('name')!, // 현재 사용자 이름 첫 글자
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text(
                            controller.prefs.getString('email')!, // 현재 사용자 이름 첫 글자
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 📄 내용 입력
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: contentController,
                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  minLines: 10, // 최소 10줄 높이
                ),
              ),

              SizedBox(height: 24),

              // 💡 작성 팁
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF34eb74).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF34eb74).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF078714), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('카테고리를 선택하고 제목과 내용을 명확하게 작성해주세요!', style: TextStyle(color: Color(0xFF078714), fontSize: 14)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 카테고리 선택 위젯
  Widget _buildCategorySelector() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF078714)))),
              SizedBox(width: 12),
              Text('카테고리 로딩 중...', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        );
      }

      return InkWell(
        onTap: () => _showCategoryBottomSheet(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.category_outlined, color: controller.selectedCategory.value != null ? Color(0xFF078714) : Colors.grey[500], size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedCategory.value?.name ?? '카테고리를 선택하세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: controller.selectedCategory.value != null ? FontWeight.w600 : FontWeight.normal,
                        color: controller.selectedCategory.value != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    if (controller.selectedCategory.value?.description.isNotEmpty == true)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(controller.selectedCategory.value!.description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[500], size: 24),
            ],
          ),
        ),
      );
    });
  }

  // ✅ 카테고리 선택 바텀시트
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 20),

            // 제목
            Text(
              '카테고리 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 20),

            // 카테고리 목록
            ...controller.categories
                .map(
                  (category) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: controller.selectedCategory.value?.categoryId == category.categoryId ? Color(0xFF078714).withOpacity(0.1) : Colors.grey[50],
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: controller.selectedCategory.value?.categoryId == category.categoryId ? Color(0xFF078714) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.category, color: controller.selectedCategory.value?.categoryId == category.categoryId ? Colors.white : Colors.grey[600], size: 20),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.selectedCategory.value?.categoryId == category.categoryId ? Color(0xFF078714) : Colors.black87,
                        ),
                      ),
                      subtitle: category.description.isNotEmpty ? Text(category.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)) : null,
                      trailing: controller.selectedCategory.value?.categoryId == category.categoryId ? Icon(Icons.check_circle, color: Color(0xFF078714)) : null,
                      onTap: () {
                        controller.selectCategory(category);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
                .toList(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
