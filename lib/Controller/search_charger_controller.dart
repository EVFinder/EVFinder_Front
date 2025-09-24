import 'dart:convert';
import 'package:evfinder_front/Service/search_by_keyword_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../Model/ev_charger.dart';
import '../Model/search_chargers.dart';
import '../Service/ev_charger_service.dart';
import 'package:flutter/material.dart';
import 'map_controller.dart';

class SearchChargerController {
  TextEditingController tController = TextEditingController();
  RxList<SearchChargers> searchResult = <SearchChargers>[].obs;
  List<EvCharger> chargers = [];
  RxBool isSearched = false.obs;

  Future<void> searchList(String query) async {
    final result = await SearchByKeywordService.searchUseKeyword(query);
    // print();
    searchResult.value = result;
  }

  Future<void> fetchChargers(double lat, double lon) async {
    List<EvCharger> resultChargers = await EvChargerService.fetchNearbyChargers(lat, lon);
    chargers = resultChargers;
    isSearched.value = true;
  }

  // 검색 결과 선택 처리
  // void selectSearchResult(int index) {
  //   final selectedPlace = searchResult[index];
  //
  //   // MapViewController로 데이터 전달하고 지도로 이동
  //   // Get.find<MapController>().moveToSelectedPlace(selectedPlace);
  //
  //   // 검색 화면 닫기
  //   Get.back(result: selectedPlace);
  // }

}
