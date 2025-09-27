import 'dart:ffi';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Service/community_service.dart';
import '../Service/post_service.dart';

class CommunityController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late ScrollController scrollController;

  // Reactive variables
  RxBool showScrollToTop = false.obs;
  RxnInt selectedCommunityIndex = RxnInt(); // null을 허용하는 RxInt
  RxList<CommunityCategory> categories = <CommunityCategory>[].obs;
  RxList<CommunityPost> post = <CommunityPost>[].obs;
  Rxn<CommunityPost> postDetail = Rxn<CommunityPost>();
  RxInt categoryCount = 0.obs;
  RxString categoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // 스크롤 리스너
  void _scrollListener() {
    if (scrollController.offset > 400 && !showScrollToTop.value) {
      showScrollToTop.value = true;
    } else if (scrollController.offset <= 400 && showScrollToTop.value) {
      showScrollToTop.value = false;
    }
  }

  // 새로고침
  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    // 실제 데이터 새로고침 로직
  }

  // 맨 위로 스크롤
  void scrollToTop() {
    scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  //------------------------------ 게시글 관련 ------------------//
  // 게시글 작성
  void createPost() {
    // 게시글 작성 로직
    print('게시글 작성');
  }

  Future<List<CommunityPost>> fetchPost(String cId) async {
    post.value = await PostService.fetchPost(cId);
    return post;
  }

  Future<CommunityPost?> fetchPostDetail(String cId, String pId) async {
    try {
      postDetail.value = await PostService.fetchPostDetail(cId, pId);
      return postDetail.value;
    } catch (e) {
      print('게시글 로드 실패: $e');
      postDetail.value = null;
      return null;
    }
  }

  // 💝 좋아요 토글
  void toggleLike(Map<String, dynamic> post) {
    print('좋아요 토글: ${post['postId']}');
    Get.snackbar('알림', (post['liked'] == true) ? '좋아요를 취소했습니다' : '좋아요를 눌렀습니다', snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
  }

  // 🗑️ 삭제 확인 다이얼로그
  void showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('게시글 삭제'),
        content: Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('취소')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
              Get.snackbar('알림', '게시글이 삭제되었습니다');
            },
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  //------------------------------ 댓글 관련 ------------------//

  //------------------------------ 커뮤니티 관련 ------------------//

  Future<bool> createCommunity(String name, String description) async {
    try {
      print('커뮤니티 생성 시작: $name');
      bool result = await CommunityService.generateCategory(name, description);
      print('커뮤니티 생성 결과: $result');
      return result;
    } catch (e) {
      print('커뮤니티 생성 오류: $e');

      // 중복 오류 구분해서 처리
      if (e.toString().contains('DUPLICATE_COMMUNITY')) {
        throw Exception('DUPLICATE_COMMUNITY'); // 중복 오류 전달
      }
      return false;
    } finally {
      initializeCategories();
    }
  }

  // 커뮤니티 선택
  void selectCommunity(int index) {
    if (selectedCommunityIndex.value != index) {
      selectedCommunityIndex.value = index;
      categoryId.value = categories[index].categoryId;
      fetchPost(categories[index].categoryId);
    }
  }

  Future<void> initializeCategories() async {
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    List<CommunityCategory> resultCategories = await CommunityService.fetchCommunityCategory();
    categoryCount.value = resultCategories.length;
    categories.value = resultCategories;
  }
}
