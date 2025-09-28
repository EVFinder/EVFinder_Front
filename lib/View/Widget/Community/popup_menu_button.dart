import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget popupMenuButton(VoidCallback editFunc, VoidCallback deleteFunc, String title, bool isCategory) {
  return PopupMenuButton<String>(
    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
    onSelected: (value) {
      if (value == 'edit') {
        editFunc();
        print('수정');
      } else if (value == 'delete') {
        if (isCategory) {
          Get.dialog(
            AlertDialog(
              title: Text('삭제'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('정말로 "$title" 카테고리를 삭제하시겠습니까?'),
                  SizedBox(height: 8),
                  Text('이 카테고리에 속한 게시글도 함께 삭제될 수 있습니다.', style: TextStyle(color: Colors.red[600], fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('취소')),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    deleteFunc();
                    Get.snackbar('성공', '카테고리가 삭제되었습니다.');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
                  child: Text('삭제', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        } else {
          Get.dialog(
            AlertDialog(
              title: Text('삭제'),
              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('정말로 "$title" 글을 삭제하시겠습니까?'), SizedBox(height: 8)]),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('취소')),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                    deleteFunc();
                    Get.snackbar('성공', '글이 삭제되었습니다.');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
                  child: Text('삭제', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      }
    },
    itemBuilder: (BuildContext context) => [
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 18, color: Color(0xFF078714)),
            SizedBox(width: 8),
            Text('수정'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('삭제', style: TextStyle(color: Colors.red[600])),
          ],
        ),
      ),
    ],
  );
}
