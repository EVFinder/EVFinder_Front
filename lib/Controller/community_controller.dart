import 'dart:ffi';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Service/category_service.dart';
import '../Service/post_service.dart';

class CommunityController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late ScrollController scrollController;

  // 컨트롤러들
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();



  // Reactive variables
  RxBool showScrollToTop = false.obs;
  final RxBool isLoadingPosts = false.obs;
  RxnInt selectedCommunityIndex = RxnInt(); // null을 허용하는 RxInt
  RxList<CommunityCategory> categories = <CommunityCategory>[].obs;
  RxList<CommunityPost> post = <CommunityPost>[].obs;
  RxList<CommunityPost> myPost = <CommunityPost>[].obs;
  Rxn<CommunityPost> postDetail = Rxn<CommunityPost>();
  RxInt categoryCount = 0.obs;
  RxString categoryId = ''.obs;
  RxInt likesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    fetchPost(categoryId.value);
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

  Future<void> initialize() async {
    await fetchCategories();
    await fetchMyPost();
  }

  //------------------------------ 게시글 관련 ------------------//
  // 게시글 작성
  Future<bool> createPost(String cId, String title, String content) async {
    try {
      print('[DEBUG] createPost 시작 - cId: $cId');

      bool isCreated = await PostService.addPost(cId, title, content);

      print('[DEBUG] PostService.addPost 성공: $isCreated');
      await fetchPost(cId);
      await fetchMyPost();
      return isCreated;
    } catch (e) {
      print('[DEBUG] PostService.addPost 실패: $e');
      return false; // ✅ 예외 발생 시 false 반환
    }
  }

  Future<List<CommunityPost>?> fetchPost(String cId) async {
    try {
      post.value = await PostService.fetchPost(cId);
      return post;
    } catch (e) {
      print('게시글 로드 실패: $e');
      postDetail.value = null;
      return null;
    }
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

  Future<List<CommunityPost>?> fetchMyPost() async {
    likesCount.value = 0;
    try {
      myPost.value = await PostService.fetchMyPost();
      likesCount.value = calLikesCount(myPost);
      return myPost;
    } catch (e) {
      print('내 게시글 로드 실패: $e');
      postDetail.value = null;
      return null;
    }
  }

  int calLikesCount(List<CommunityPost> posts) {
    int likes = 0;
    for (CommunityPost post in posts) {
      likes += post.likes ?? 0;
    }
    return likes;
  }

  Future<String> editPost(String pId, String title, String content) async {
    List<CommunityPost>? forCid = await fetchMyPost();
    for (CommunityPost post in forCid!) {
      if (post.postId == pId) {
        await PostService.editPost(post.categoryId, pId, title, content);
        return post.categoryId;
      }
    }
    return '';
  }

  Future<bool> deletePost(String cId, String pId) async {
    bool result = await PostService.deletePost(cId, pId);
    if (result) {
      await fetchPost(cId);
      await fetchMyPost();
      return true;
    } else {
      return false;
    }
  }

  // 💝 좋아요 토글
  void toggleLike(Map<String, dynamic> post) {
    print('좋아요 토글: ${post['postId']}');
    Get.snackbar('알림', (post['liked'] == true) ? '좋아요를 취소했습니다' : '좋아요를 눌렀습니다', snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
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

      // 특정 오류들은 그대로 전달 (변환하지 않음)
      if (e.toString().contains('DUPLICATE_COMMUNITY') || e.toString().contains('UNAUTHORIZED') || e.toString().contains('FORBIDDEN') || e.toString().contains('CREATION_FAILED')) {
        // 이것도 추가
        rethrow; // 원본 예외를 그대로 전달
      }
      throw Exception('CREATION_ERROR');
    } finally {
      initialize();
    }
  }

  // 커뮤니티 선택
  void selectCommunity(int index) {
    // selectCommunity 메서드 수정
    selectedCommunityIndex.value = index;
    categoryId.value = categories[index].categoryId;
    // 로딩 시작
    isLoadingPosts.value = true;
    try {
      fetchPost(categories[index].categoryId);
    } finally {
      // 로딩 완료
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchCategories() async {
    List<CommunityCategory> resultCategories = await CommunityService.fetchCommunityCategory();
    categoryCount.value = resultCategories.length;
    categories.value = resultCategories;
  }

  // ✅ 선택된 카테고리 추가
  Rx<CommunityCategory?> selectedCategory = Rx<CommunityCategory?>(null);

  // 카테고리 선택 메서드
  void selectCategory(CommunityCategory category) {
    selectedCategory.value = category;
  }

  // 카테고리 초기화
  void clearSelectedCategory() {
    selectedCategory.value = null;
  }
}
