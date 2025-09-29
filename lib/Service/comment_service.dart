import 'dart:convert';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Model/community_comment.dart';

class CommentService {
  static Future<bool> createComment(String cId, String pId, String comment, String? parentId) async {
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';
    final body = {'content': comment, 'parentId': parentId};

    final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/comments');

    final createResponse = await http.post(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

    print('[DEBUG] Add Comment 응답 코드: ${createResponse.statusCode}');
    print('[DEBUG] Add Comment 응답 내용: ${createResponse.body}');

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('[SUCCESS] 댓글 생성 성공');
      return true;
    } else {
      return false;
    }
  }

  static Future<List<CommunityComment>?> fetchComment(String cId, String pId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jwt = prefs.getString('jwt') ?? '';

      final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/comments/list');
      final createResponse = await http.get(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

      print('[DEBUG] Fetch Comment 응답 코드: ${createResponse.statusCode}');
      print('[DEBUG] Fetch Comment 응답 내용: ${createResponse.body}');
      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        print('[SUCCESS] 댓글 조회 성공');
        // JSON 응답 파싱
        final List<dynamic> jsonList = json.decode(createResponse.body);
        // CommunityComment 객체 리스트로 변환
        List<CommunityComment> comments = jsonList.map((json) => CommunityComment.fromJson(json)).toList();
        // 시간순 정렬
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return comments;
      } else {
        print('[ERROR] 댓글 조회 실패: ${createResponse.statusCode}');
        print('[ERROR] 에러 내용: ${createResponse.body}');
        return null;
      }
    } catch (e) {
      print('[ERROR] 댓글 조회 중 예외 발생: $e');
      return null;
    }
  }

  static Future<bool> editComment(String cId, String pId, String commentId, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';
    final body = {'content': comment};

    final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/comments/$commentId');

    final createResponse = await http.put(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

    print('[DEBUG] Edit Comment 응답 코드: ${createResponse.statusCode}');
    print('[DEBUG] Edit Comment 응답 내용: ${createResponse.body}');

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('[SUCCESS] 댓글 수정 성공');
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> deleteComment(String cId, String pId, String commentId, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId/posts/$pId/comments/$commentId');

    final createResponse = await http.delete(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});

    print('[DEBUG] Delete Comment 응답 코드: ${createResponse.statusCode}');
    print('[DEBUG] Delete Comment 응답 내용: ${createResponse.body}');

    if (createResponse.statusCode == 204) {
      print('[SUCCESS] 댓글 삭제 성공');
      return true;
    } else {
      return false;
    }
  }
}
