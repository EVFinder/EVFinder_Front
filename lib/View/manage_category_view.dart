import 'package:evfinder_front/View/Widget/Community/popup_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/community_controller.dart';
import '../Model/community_category.dart';
import 'Widget/Community/add_category_dialog_widget.dart';
import 'Widget/Community/edit_category_widget.dart';

class ManageCategoryView extends GetView<CommunityController> {
  ManageCategoryView({super.key});

  static String route = '/managecategory';

  @override
  Widget build(BuildContext context) {
    // 화면 진입 시 카테고리 데이터 로드
    controller.fetchCategories();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('카테고리 관리', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            // 상단 정보 카드
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFF078714).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.category, color: Color(0xFF078714), size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전체 카테고리',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${controller.categories.length}개',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF078714)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 카테고리 리스트
            Obx(() {
              return Expanded(
                child: controller.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text('카테고리가 없습니다.', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          return _buildCategoryTile(context, category);
                        },
                      ),
              );
            }),
          ],
        ),
      ),

      // 카테고리 추가 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddCategoryDialog(context);
          controller.fetchCategories();
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('카테고리 추가', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF078714),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, CommunityCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Color(0xFF078714).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.folder, color: Color(0xFF078714), size: 24),
        ),
        title: Text(
          category.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: category.description.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  category.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: popupMenuButton(
          () {
            _showEditCategoryDialog(context, category);
          },
          () {
            controller.deleteCategory(category.categoryId, category.name, category.description);
          },
          category.name,
          true,
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showCreateCategoryDialog(controller);
  }

  void _showEditCategoryDialog(BuildContext context, CommunityCategory category) {
    showEditCategoryDialog(controller, category);
  }
}
