import 'dart:convert';
import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Model/community_post.dart';

class PostService {
  static Future<List<CommunityPost>> fetchPost(String cId) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/list');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});
    print('[DEBUG] Fetch Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Fetch Post 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => CommunityPost.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load community categories');
    }
  }

  static Future<CommunityPost> fetchPostDetail(String cId, String pId) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

    print('[DEBUG] Fetch Detail Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Fetch Detail Post 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      // 🔥 수정: 단일 객체로 처리
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return CommunityPost.fromJson(jsonData);
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }
}
