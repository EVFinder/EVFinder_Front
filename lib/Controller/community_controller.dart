import 'package:evfinder_front/Model/community_category.dart';
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

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    fetchCategories();
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

  // 게시글 작성
  void createPost() {
    // 게시글 작성 로직
    print('게시글 작성');
  }

  // 커뮤니티 생성
  void createCommunity() {
    // 커뮤니티 생성 로직
    print('커뮤니티 생성');
  }

  // 커뮤니티 선택
  void selectCommunity(int index) {
    selectedCommunityIndex.value = index;
  }

  Future<void> fetchCategories() async {
    List<CommunityCategory> resultCategories = await CommunityService.fetchCommunityCategory();
    categories.value = resultCategories;
    print(categories);
  }
}
