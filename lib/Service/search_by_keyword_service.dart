import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import '../Constants/api_constants.dart';
import '../Model/search_chargers.dart';
import 'package:http/http.dart' as http;

class SearchByKeywordService {
  static Future<List<SearchChargers>> searchUseKeyword(String? query) async {
    if (query == null || query.isEmpty) {
      Get.snackbar('실패', '검색어를 입력해주세요.', snackPosition: SnackPosition.BOTTOM);
      return [];
    } else {
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
}
