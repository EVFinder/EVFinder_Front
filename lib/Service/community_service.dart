import 'dart:convert';

import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Model/ev_charger.dart';

class CommunityService {
  static Future<List<CommunityCategory>> fetchCommunityCategory() async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});
    print('[DEBUG] Fetch Category 응답 코드: ${response.statusCode}');
    print('[DEBUG] Fetch Category 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => CommunityCategory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load community categories');
    }
  }

  static Future<bool> generateCategory(String name, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    try {
      List<CommunityCategory> existingCategories = await fetchCommunityCategory();
      // 대소문자 구분 없이 중복 체크
      bool isDuplicate = existingCategories.any((category) => category.name.toLowerCase() == name.toLowerCase());

      if (isDuplicate) {
        print('[DEBUG] 이미 존재하는 커뮤니티: $name');
        throw Exception('DUPLICATE_COMMUNITY');
      }

      final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories');
      final body = {'name': name, 'description': description};

      final createResponse = await http.post(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

      print('[DEBUG] 생성 응답 코드: ${createResponse.statusCode}');
      print('[DEBUG] 생성 응답 내용: ${createResponse.body}');

      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        print('[SUCCESS] 커뮤니티 생성 성공: $name');
        return true;
      } else {
        print('[ERROR] 커뮤니티 생성 실패: ${createResponse.statusCode}');
        throw Exception('CREATION_FAILED');
      }
    } catch (e) {
      print('[ERROR] generateCategory 오류: $e');

      // 중복 오류는 특별히 처리
      if (e.toString().contains('DUPLICATE_COMMUNITY')) {
        throw Exception('DUPLICATE_COMMUNITY');
      }
      throw Exception('CREATION_ERROR');
    }
  }
}
