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
      } else if (createResponse.statusCode == 401) {
        // 인증 실패
        print('[ERROR] 인증 실패: JWT 토큰이 유효하지 않음');
        throw Exception('UNAUTHORIZED');
      } else if (createResponse.statusCode == 403) {
        // 권한 없음 (admin이 아님)
        print('[ERROR] 권한 없음: 관리자 권한이 필요함');
        throw Exception('FORBIDDEN');
      } else {
        print('[ERROR] 커뮤니티 생성 실패: ${createResponse.statusCode}');
        throw Exception('CREATION_FAILED');
      }
    } catch (e) {
      print('[ERROR] generateCategory 오류: $e');

      // 특정 오류들은 그대로 전달
      if (e.toString().contains('DUPLICATE_COMMUNITY') || e.toString().contains('UNAUTHORIZED') || e.toString().contains('FORBIDDEN')) {
        rethrow;
      }
      throw Exception('CREATION_ERROR');
    }
  }

  static Future<bool> editCategory(String cId, String name, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    try {
      List<CommunityCategory> existingCategories = await fetchCommunityCategory();
      bool isDuplicate = existingCategories.any((category) => category.name.toLowerCase() == name.toLowerCase());

      if (isDuplicate) {
        print('[DEBUG] 이미 존재하는 카테고리: $name');
        throw Exception('DUPLICATE_COMMUNITY');
      }

      final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories/$cId');
      final body = {'name': name, 'description': description};

      final createResponse = await http.put(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));

      print('[DEBUG] Edit Category 응답 코드: ${createResponse.statusCode}');
      print('[DEBUG] Edit Category 응답 내용: ${createResponse.body}');

      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        print('[SUCCESS] 카테고리 수정 성공: $name');
        return true;
      } else if (createResponse.statusCode == 401) {
        // 인증 실패
        print('[ERROR] 인증 실패: JWT 토큰이 유효하지 않음');
        throw Exception('UNAUTHORIZED');
      } else if (createResponse.statusCode == 403) {
        // 권한 없음 (admin이 아님)
        print('[ERROR] 권한 없음: 관리자 권한이 필요함');
        throw Exception('FORBIDDEN');
      } else {
        print('[ERROR] 카테고리 수정 실패: ${createResponse.statusCode}');
        throw Exception('CREATION_FAILED');
      }
    } catch (e) {
      print('[ERROR] generateCategory 오류: $e');

      // 특정 오류들은 그대로 전달
      if (e.toString().contains('DUPLICATE_COMMUNITY') || e.toString().contains('UNAUTHORIZED') || e.toString().contains('FORBIDDEN')) {
        rethrow;
      }
      throw Exception('CREATION_ERROR');
    }
  }


  // static Future<bool> deleteCategory(String name, String description) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String jwt = prefs.getString('jwt') ?? '';
  //
  //   try {
  //     List<CommunityCategory> existingCategories = await fetchCommunityCategory();
  //     bool isDuplicate = existingCategories.any((category) => category.name.toLowerCase() == name.toLowerCase());
  //
  //     if (isDuplicate) {
  //       print('[DEBUG] 이미 존재하는 커뮤니티: $name');
  //       throw Exception('DUPLICATE_COMMUNITY');
  //     }
  //
  //     final createUrl = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories');
  //     final body = {'name': name, 'description': description};
  //
  //     final createResponse = await http.post(createUrl, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'}, body: json.encode(body));
  //
  //     print('[DEBUG] 생성 응답 코드: ${createResponse.statusCode}');
  //     print('[DEBUG] 생성 응답 내용: ${createResponse.body}');
  //
  //     if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
  //       print('[SUCCESS] 커뮤니티 생성 성공: $name');
  //       return true;
  //     } else if (createResponse.statusCode == 401) {
  //       // 인증 실패
  //       print('[ERROR] 인증 실패: JWT 토큰이 유효하지 않음');
  //       throw Exception('UNAUTHORIZED');
  //     } else if (createResponse.statusCode == 403) {
  //       // 권한 없음 (admin이 아님)
  //       print('[ERROR] 권한 없음: 관리자 권한이 필요함');
  //       throw Exception('FORBIDDEN');
  //     } else {
  //       print('[ERROR] 커뮤니티 생성 실패: ${createResponse.statusCode}');
  //       throw Exception('CREATION_FAILED');
  //     }
  //   } catch (e) {
  //     print('[ERROR] generateCategory 오류: $e');
  //
  //     // 특정 오류들은 그대로 전달
  //     if (e.toString().contains('DUPLICATE_COMMUNITY') || e.toString().contains('UNAUTHORIZED') || e.toString().contains('FORBIDDEN')) {
  //       rethrow;
  //     }
  //     throw Exception('CREATION_ERROR');
  //   }
  // }

}
