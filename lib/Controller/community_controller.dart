import 'dart:ffi';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:evfinder_front/Model/community_post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/community_comment.dart';
import '../Service/category_service.dart';
import '../Service/comment_service.dart';
import '../Service/post_service.dart';

class CommunityController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late ScrollController scrollController;
  RxBool showScrollToTop = false.obs;
  late SharedPreferences prefs;

  // Reactive variables
  final RxBool isLoadingPosts = false.obs;
  RxBool isAdmin = false.obs;

  //====Category===
  RxnInt selectedCommunityIndex = RxnInt(); // null을 허용하는 RxInt
  RxList<CommunityCategory> categories = <CommunityCategory>[].obs;
  RxInt categoryCount = 0.obs;
  RxString categoryId = ''.obs;

  //====Post===
  RxList<CommunityPost> post = <CommunityPost>[].obs;
  RxList<CommunityPost> myPost = <CommunityPost>[].obs;
  Rxn<CommunityPost> postDetail = Rxn<CommunityPost>();
  RxInt likesCount = 0.obs;

  //====Commnet===
  var comments = <CommunityComment>[].obs;
  var isLoadingComment = false.obs;
  RxMap<String, bool> commentExpandStates = <String, bool>{}.obs;
  RxMap<String, int> postCommentCounts = <String, int>{}.obs;

  // 댓글 수정 상태 관리
  RxMap<String, bool> editingComments = <String, bool>{}.obs;
  RxMap<String, TextEditingController> editControllers = <String, TextEditingController>{}.obs;

  // 대댓글 관련 변수 추가
  RxString replyingToCommentId = ''.obs; // 현재 답글 중인 댓글 ID
  RxBool isReplying = false.obs; // 답글 모드 여부

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
    // ✅ 모든 편집 컨트롤러 해제
    for (var controller in editControllers.values) {
      controller.dispose();
    }
    editControllers.clear();

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
    prefs = await SharedPreferences.getInstance();
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
  // 특정 게시글의 댓글 개수를 가져오는 메서드
  Future<int> getCommentCount(String cId, String pId) async {
    try {
      String key = '${cId}_$pId';
      if (postCommentCounts.containsKey(key)) {
        return postCommentCounts[key]!;
      }

      List<CommunityComment>? fetchedComments = await CommentService.fetchComment(cId, pId);

      if (fetchedComments != null) {
        int count = fetchedComments.length;
        postCommentCounts[key] = count;
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('[ERROR] 댓글 개수 가져오기 실패: $e');
      return 0;
    }
  }

  Future<void> createComment(String cId, String pId, String comment, String? parentId) async {
    try {
      bool isCreated = await CommentService.createComment(cId, pId, comment, parentId);
      if (isCreated) {
        fetchComment(cId, pId);
        // 캐시 업데이트
        String key = '${cId}_$pId';
        if (postCommentCounts.containsKey(key)) {
          postCommentCounts[key] = postCommentCounts[key]! + 1;
        }
        print('댓글 작성 성공');
      }
    } catch (e) {
      print('댓글 작성 실패: $e');
    }
  }

  Future<void> fetchComment(String cId, String pId) async {
    try {
      comments.clear();
      isLoadingComment.value = true;
      List<CommunityComment>? fetchedComments = await CommentService.fetchComment(cId, pId);

      if (fetchedComments != null) {
        comments.value = fetchedComments;
        // 캐시 업데이트
        String key = '${cId}_$pId';
        postCommentCounts[key] = fetchedComments.length;
        print('[SUCCESS] ${fetchedComments.length}개의 댓글을 불러왔습니다.');
      } else {
        print('[ERROR] 댓글을 불러오는데 실패했습니다.');
        Get.snackbar('오류', '댓글을 불러오는데 실패했습니다.');
      }
    } finally {
      isLoadingComment.value = false;
    }
  }

  void startEditComment(String commentId, String currentContent) {
    editingComments[commentId] = true;
    editControllers[commentId] = TextEditingController(text: currentContent);
  }

  void cancelEditComment(String commentId) {
    editingComments[commentId] = false;
    editControllers[commentId]?.dispose();
    editControllers.remove(commentId);
  }

  Future<void> updateComment(String commentId) async {
    try {
      final content = editControllers[commentId]?.text ?? '';
      if (content.trim().isEmpty) {
        Get.snackbar('오류', '댓글 내용을 입력해주세요.');
        return;
      }

      String cId = '';
      String pId = '';

      if (postDetail.value != null) {
        cId = postDetail.value!.categoryId.isNotEmpty ? postDetail.value!.categoryId : categoryId.value;
        pId = postDetail.value!.postId;
      } else {
        Get.snackbar('오류', '게시글 정보를 찾을 수 없습니다.');
        return;
      }

      if (cId.isEmpty) {
        Get.snackbar('오류', '카테고리 정보를 찾을 수 없습니다.');
        return;
      }

      final success = await CommentService.editComment(cId, pId, commentId, content.trim());

      if (success) {
        final index = comments.indexWhere((c) => c.commentId == commentId);
        if (index != -1) {
          comments[index] = comments[index].copyWith(content: content.trim(), updatedAt: DateTime.now());
        }
        cancelEditComment(commentId);
        Get.snackbar('성공', '댓글이 수정되었습니다.', backgroundColor: Colors.green[100], colorText: Colors.green[800]);
      } else {
        Get.snackbar('오류', '댓글 수정에 실패했습니다.', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
      }
    } catch (e) {
      print('[ERROR] 댓글 수정 중 오류: $e');
      Get.snackbar('오류', '댓글 수정 중 오류가 발생했습니다.', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('댓글 삭제'),
          content: Text('정말로 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('취소', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (result != true) return;

      String cId = '';
      String pId = '';

      if (postDetail.value != null) {
        cId = postDetail.value!.categoryId.isNotEmpty ? postDetail.value!.categoryId : categoryId.value;
        pId = postDetail.value!.postId;
      } else {
        Get.snackbar('오류', '게시글 정보를 찾을 수 없습니다.');
        return;
      }

      if (cId.isEmpty) {
        Get.snackbar('오류', '카테고리 정보를 찾을 수 없습니다.');
        return;
      }

      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final success = await CommentService.deleteComment(cId, pId, commentId, '');
      Get.back();

      if (success) {
        // 삭제된 댓글과 대댓글 개수 계산
        int deletedCount = 1; // 삭제된 댓글
        deletedCount += comments.where((c) => c.parentId == commentId).length; // 대댓글들

        comments.removeWhere((c) => c.commentId == commentId);
        comments.removeWhere((c) => c.parentId == commentId);

        // 캐시 업데이트
        String key = '${cId}_$pId';
        if (postCommentCounts.containsKey(key)) {
          postCommentCounts[key] = (postCommentCounts[key]! - deletedCount).clamp(0, double.infinity).toInt();
        }

        Get.snackbar('성공', '댓글이 삭제되었습니다.', backgroundColor: Colors.green[100], colorText: Colors.green[800]);
      } else {
        Get.snackbar('오류', '댓글 삭제에 실패했습니다.', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print('[ERROR] 댓글 삭제 중 오류: $e');
      Get.snackbar('오류', '댓글 삭제 중 오류가 발생했습니다.', backgroundColor: Colors.red[100], colorText: Colors.red[800]);
    }
  }

  bool isEditingComment(String commentId) {
    return editingComments[commentId] ?? false;
  }

  List<CommunityComment> get parentComments {
    return comments.where((comment) => comment.parentId == null).toList();
  }

  List<CommunityComment> getReplies(String parentId) {
    return comments.where((comment) => comment.parentId == parentId).toList();
  }

  void cancelReply() {
    replyingToCommentId.value = '';
    isReplying.value = false;
  }

  void startReply(String commentId) {
    replyingToCommentId.value = commentId;
    isReplying.value = true;
  }

  void toggleCommentExpand(String commentId) {
    commentExpandStates[commentId] = !(commentExpandStates[commentId] ?? true);
  }

  bool isCommentExpanded(String commentId) {
    return commentExpandStates[commentId] ?? true;
  }

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
