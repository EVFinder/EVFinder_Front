import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';

class ReviewDetailController extends GetxController {
  final reviews = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  static String route = "/reviewdetail";
  final uid = ''.obs;

  final sortOrder = 'latest'.obs; // 'latest' 또는 'rating'
  String? stationId;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserUid();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      stationId = arguments['id']?.toString();
    }
    if (stationId != null) {
      loadReviews();
    }
  }

  Future<void> loadCurrentUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
  }

  void changeSortOrder(String newOrder) {
    if (sortOrder.value != newOrder) {
      sortOrder.value = newOrder;
      loadReviews();
    }
  }

  Future<void> loadReviews() async {
    isLoading.value = true;
    try {
      final rawReviews = await fetchReviews(stationId!, sortOrder.value);
      reviews.assignAll(
          rawReviews.map (
              (e) =>
                  {
                    "reviewId": e['reviewId']?.toString() ?? '알 수 없음',
                    "id": e['id']?.toString() ?? '알 수 없음',
                    "name": e['name']?.toString() ?? '알 수 없음',
                    "uid": e['uid']?.toString() ?? '알 수 없음',
                    "userName": e['userName']?.toString() ?? '알 수 없음',
                    "rating":  e['rating'] ?? 0,
                    "content": e['content']?.toString() ?? '알 수 없음',
                    "createdAt": e['createdAt']?.toString() ?? '알 수 없음',
                    "updatedAt": e['updatedAt']?.toString() ?? '알 수 없음',
                  },
          ));
    } finally {
      isLoading.value = false;
    }
  }

  Future <void> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;

      final url = Uri.parse('${ApiConstants.reviewBaseUrl}/delete/$uid/$reviewId');
      final response = await http.delete(url);

      print("리뷰 삭제 응답 코드: ${response.statusCode}");
      print("리뷰 삭제 내용: ${utf8.decode(response.bodyBytes)}");

      if(response.statusCode == 200) {
        Get.snackbar('', '리뷰가 삭제되었습니다.', snackPosition: SnackPosition.BOTTOM);
        loadReviews();
      } else {
        Get.snackbar('', '리뷰 삭제를 실패하었습니다.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String stationId, String order) async {
    String orderBy;
    if (order == 'rating') {
      orderBy = 'rating';
    } else {
      orderBy = 'createdAt';
    }

    final urlString = '${ApiConstants.reviewBaseUrl}/list/station/$stationId?orderBy=${orderBy}';
    final url = Uri.parse(urlString);

    print("Requesting All Reviews URL: $url");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json);
    } else {
      throw Exception('Failed to fetch reviews');
    }
  }
}

