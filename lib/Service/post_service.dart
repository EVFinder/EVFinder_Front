import 'dart:convert';
import 'package:evfinder_front/Model/community_category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Model/ev_charger.dart';

class PostService {
  static Future<List<CommunityCategory>> fetchPost() async {
    final url = Uri.parse('${ApiConstants.communityApiBaseUrl}/categories');
    final prefs = await SharedPreferences.getInstance();
    final String jwt = prefs.getString('jwt') ?? '';

    final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": 'Bearer $jwt'});
    print('[DEBUG] 응답 코드: ${response.statusCode}');
    print('[DEBUG] 응답 내용: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => CommunityCategory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load community categories');
    }
  }


}
