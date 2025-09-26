import 'dart:convert';

import 'package:evfinder_front/Model/weather.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';

class WeatherService {
  static Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse('${ApiConstants.weatherApiBaseUrl}?lat=$lat&lon=$lon');
    final response = await http.get(url);
    // print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return Weather.fromJson(decoded);
    } else {
      throw Exception('검색 결과를 불러오지 못했습니다.');
    }
  }

  static Future<String> chageCoorToAddr(double lat, double lon) async {
    final url = Uri.parse('${ApiConstants.coorToAddr}?x=$lon&y=$lat');
    final response = await http.get(url);
    // print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return decoded['addressName'];
    } else {
      throw Exception('검색 결과를 불러오지 못했습니다.');
    }
  }
}
