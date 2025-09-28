import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Model/community_category.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

void showEditCategoryDialog(CommunityController controller, CommunityCategory category) {
  final TextEditingController nameController = TextEditingController(text: category.name);
  final TextEditingController descriptionController = TextEditingController(text: category.description);
  final RxBool isLoading = false.obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.group_add, color: Colors.green, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('커뮤니티 수정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('새로운 커뮤니티를 수정합니다', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 24),

            // 커뮤니티 이름 입력
            Text(
              '커뮤니티 이름',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.title, color: Colors.grey[600]),
              ),
              maxLength: 50,
              textInputAction: TextInputAction.next,
            ),

            SizedBox(height: 16),

            // 커뮤니티 설명 입력
            Text(
              '커뮤니티 설명',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
              ),
              maxLines: 3,
              maxLength: 200,
              textInputAction: TextInputAction.done,
            ),

            SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text('취소', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final description = descriptionController.text.trim();

                              if (isLoading.value) return;

                              try {
                                isLoading.value = true;
                                print('커뮤니티 생성 중...');

                                bool result = await controller.editCategory(category.categoryId, name, description);

                                if (result) {
                                  Get.back(); // 다이얼로그 닫기
                                  Get.snackbar(
                                    '성공',
                                    '커뮤니티 "$name"이 성공적으로 수정되었습니다!',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green[100],
                                    colorText: Colors.green[800],
                                    icon: Icon(Icons.check_circle, color: Colors.green),
                                  );
                                }
                              } catch (e) {
                                print('[ERROR] 커뮤니티 수정 과정 실패: $e');
                              } finally {
                                isLoading.value = false;
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isLoading.value
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : Text(
                              '수정',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // 바깥 터치로 닫기 방지
  );
}
