import 'package:evfinder_front/View/Widget/add_charge_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/addCharge_controller.dart';

class AddChargeView extends GetView<AddChargeController> {
  const AddChargeView({super.key});
  static String route = "/addcharge";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 충전소"),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12),
          child: TextButton(
              onPressed: () {
                Get.toNamed('/register/new'); //충전소 등록 페이지로 이동해야 함
              },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
              shape: const StadiumBorder(),
          ),
            child: const Text(
              '+ 새 충전소 등록',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          AddChargeCard(
              stationName: '공유 충전소',
              stationAddress: '충주',
              operatingHours: '14:00-16:00',
              chargerStat: 1,
              distance: '200m')
        ],
      )
    );
  }
}