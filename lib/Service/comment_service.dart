import 'dart:convert';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';

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
}
