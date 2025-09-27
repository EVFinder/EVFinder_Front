import 'dart:ffi';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Service/community_service.dart';

class CommunityController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late ScrollController scrollController;

  // Reactive variables
  RxBool showScrollToTop = false.obs;
  RxnInt selectedCommunityIndex = RxnInt(); // null을 허용하는 RxInt
  RxList<CommunityCategory> categories = <CommunityCategory>[].obs;
  RxInt categoryCount = 0.obs;

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

  void fetchPost () {

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
    selectedCommunityIndex.value = index;
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
