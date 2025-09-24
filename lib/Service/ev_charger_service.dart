import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/ev_charger.dart';
import '../Model/ev_charger_detail.dart';
import '../constants/api_constants.dart';

class EvChargerService {
  static Future<List<EvCharger>> fetchNearbyChargers(double lat, double lon) async {
    final url = Uri.parse('${ApiConstants.evApiBaseUrl}nearby?lat=$lat&lon=$lon');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // final decoded = json.decode(response.body);
      final List chargers = json.decode(response.body);
      return chargers.map((e) => EvCharger.fromJson(e)).toList();
    } else {
      throw Exception('충전소 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<List<EvCharger>> fetchOneBuildingChargers(double lat, double lon) async {
    final url = Uri.parse('${ApiConstants.evApiBaseUrl}nearbyOO?lat=$lat&lon=$lon');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // final decoded = json.decode(response.body);
      final List chargers = json.decode(response.body);
      return chargers.map((e) => EvCharger.fromJson(e)).toList();
    } else {
      throw Exception('충전소 데이터를 불러오지 못했습니다.');
    }
  }
}
