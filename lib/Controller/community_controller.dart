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
  RxBool isAdmin = false.obs;
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

  void getRole() async {
    String role = await CommunityService.getRole();
    if (role == 'ADMIN') {
      isAdmin.value = true;
    } else {
      isAdmin.value = false;
    }
  }

  Future<void> initialize() async {
    getRole();
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
      post.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      myPost.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  Future<bool> updateLike(String way, String cId, String pId) async {
    bool result = await PostService.updateLike(way, cId, pId);
    if (result) {
      fetchPost(cId);
      fetchMyPost();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> fetchLike(String cId, String pId) async {
    bool result = await PostService.fetchLike(cId, pId);
    if (result) {
      return true;
    } else {
      return false;
    }
  }

  //------------------------------ 댓글 관련 ------------------//

  //------------------------------ 커뮤니티 관련 ------------------//

  Future<bool> createCategory(String name, String description) async {
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

  Future<bool> editCategory(String cId, String name, String description) async {
    bool result = await CommunityService.editCategory(cId, name, description);
    if (result) {
      fetchCategories();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteCategory(String cId, String name, String description) async {
    bool result = await CommunityService.deleteCategory(cId, name, description);
    if (result) {
      await fetchCategories();
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchCategories() async {
    List<CommunityCategory> resultCategories = await CommunityService.fetchCommunityCategory();
    categoryCount.value = resultCategories.length;
    categories.value = resultCategories;
    categories.sort((a, b) => a.name.compareTo(b.name));
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
