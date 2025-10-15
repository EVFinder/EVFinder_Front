import 'package:evfinder_front/Controller/bnb_station_controller.dart';
import 'package:evfinder_front/Controller/search_charger_controller.dart';
import 'package:evfinder_front/View/Widget/bnb_charge_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ↓ 필요 시 경로 조정
import 'package:evfinder_front/View/search_charger_view.dart';
import 'package:evfinder_front/Model/ev_charger.dart';
import 'package:evfinder_front/View/Widget/search_appbar_widget.dart';

import '../Model/search_chargers.dart';

class BnbStationView extends GetView<BnbStationController> {
  const BnbStationView({super.key});

  static String route = "/bnbcharge";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text("공유 충전소 목록"), backgroundColor: Color(0xFFF7F9FC)),
      // 1. Column을 사용하여 위젯들을 세로로 배치합니다.
      body: Column(
        children: [
          // 2. 검색 위젯을 항상 상단에 표시합니다.
          SearchAppbarWidget(
            topPadding: 0,
            onTap: () async {
              final result = await Get.to(() => const SearchChargerView(searchType: SearchType.bnb));
              if (result != null && result is SearchChargers) {
                controller.lat.value = double.parse(result.y);
                controller.lon.value = double.parse(result.x);

                controller.loadBnbCharge(lat: controller.lat.value, lon: controller.lon.value);
              }
            },
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.bnbchargeStation.isEmpty) {
                return const Center(child: Text("공유 충전소가 없습니다."));
              }
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                    itemCount: controller.bnbchargeStation.length,
                    itemBuilder: (context, index) {
                      final station = controller.bnbchargeStation[index];

                      final raw = (station['status'] ?? '').toString();
                      final statusText = raw == 'available'
                          ? '사용 가능'
                          : raw == 'unavailable'
                          ? '사용 불가'
                          : '알 수 없음';

                      return BnbChargeCard(
                        stationName: station['stationName'],
                        stationAddress: station['address'],
                        chargerStat: statusText,
                        chargerType: station['chargerType'],
                        pricePerHour: station['pricePerHour'],
                        power: station['power'],
                        onTap: () => Get.toNamed('/detail', arguments: {'station': station}),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
