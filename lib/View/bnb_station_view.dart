import 'package:evfinder_front/Controller/bnb_station_controller.dart';
import 'package:evfinder_front/View/Widget/bnb_charge_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BnbStationView extends GetView<BnbStationController> {
  const BnbStationView({super.key});
  static String route = "/bnbcharge";

  @override
  Widget build(BuildContext context) {
    controller.loadBnbCharge();
    return Scaffold(
        appBar: AppBar(
          title: const Text("공유 충전소 목록"),
        ),
        body: Obx(() {
          if(controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if(controller.bnbchargeStation.isEmpty) {
            return const Center(child: Text("공유 충전소가 없습니다."));
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                itemCount: controller.bnbchargeStation.length,
                itemBuilder: (context, index) {
                  final station = controller.bnbchargeStation[index];
                  return BnbChargeCard(
                    stationName: station['stationName'],
                    stationAddress: station['address'],
                    chargerStat: station['status'],
                    chargerType: station['chargerType'],
                    pricePerHour: station['pricePerHour'],
                    power: station['power'],
                    onTap: () => Get.toNamed('/detail', arguments: station),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          );
        })
    );
  }
}