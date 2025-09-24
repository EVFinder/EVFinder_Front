import 'dart:convert';

import '../Constants/api_constants.dart';
import '../Model/search_chargers.dart';
import 'package:http/http.dart' as http;


class SearchByKeywordService {
  static Future<List<SearchChargers>> searchUseKeyword(String query) async {
    final url = Uri.parse('${ApiConstants.keywordPlaceApiUrl}?query=$query');
    final response = await http.get(url);
    // print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((e) => SearchChargers.fromJson(e)).toList();
    } else {
      throw Exception('검색 결과를 불러오지 못했습니다.');
    }
  }
}
