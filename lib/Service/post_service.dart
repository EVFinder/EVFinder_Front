import 'dart:convert';
import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Model/community_post.dart';

class PostService {
  static Future<List<CommunityPost>> fetchPost(String cId) async {
    if (cId != null) {
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
        throw Exception('Failed to load community post');
      }
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
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return CommunityPost.fromJson(jsonData);
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  static Future<List<CommunityPost>> fetchMyPost() async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/my/posts');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

    print('[DEBUG] Fetch My Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Fetch My Post 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => CommunityPost.fromJson(e)).toList();
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  static Future<bool> addPost(String cId, String title, String content) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final body = {"title": title, "content": content};

    final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

    print('[DEBUG] Fetch Add Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Fetch Add Post 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  static Future<bool> editPost(String cId, String pId, String title, String content) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';
    final body = {"title": title, "content": content};

    final response = await http.put(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

    print('[DEBUG] Edit Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Edit Post 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('게시글을 수정하는데 실패했습니다: ${response.statusCode}');
    }
  }

  static Future<bool> deletePost(String cId, String pId) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.delete(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

    print('[DEBUG] Delete Post 응답 코드: ${response.statusCode}');
    print('[DEBUG] Delete Post 응답 내용: ${response.body}');

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('게시글을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  static Future<bool> updateLike(String way, String cId, String pId) async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/like');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    late final http.Response response;
    if (way == "add") {
      response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

      print('[DEBUG] Add Like 응답 코드: ${response.statusCode}');
      print('[DEBUG] Add Like 응답 내용: ${response.body}');
    } else if (way == "remove") {
      response = await http.delete(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

      print('[DEBUG] Delete Like 응답 코드: ${response.statusCode}');
      print('[DEBUG] Delete Like 응답 내용: ${response.body}');
    }
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('좋아요 업데이트 실패: ${response.statusCode}');
    }
  }

  static Future<bool> fetchLike(String cId, String pId) async {
    try {
      final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/islike');
      final prefs = await SharedPreferences.getInstance();
      final String jwt = prefs.getString('jwt') ?? '';

      final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

      print('[DEBUG] Fetch Like 응답 코드: ${response.statusCode}');
      print('[DEBUG] Fetch Like 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        // JSON 파싱
        final Map<String, dynamic> data = json.decode(response.body);
        return data['isLiked'] ?? false; // isLiked 값 반환, 없으면 false
      } else {
        throw Exception('좋아요 상태를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] fetchLike 오류: $e');
      return false; // 오류 시 기본값 false 반환
    }
  }
}
