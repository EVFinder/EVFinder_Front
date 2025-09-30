import 'package:evfinder_front/View/Widget/add_charge_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/addCharge_controller.dart';

class AddChargeView extends GetView<AddChargeController> {
  const AddChargeView({super.key});
  static String route = "/addcharge";

  @override
  Widget build(BuildContext context) {
    controller.loadHostCharge();
    return Scaffold(
        backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("내 충전소"),
        backgroundColor: Color(0xFFF7F9FC),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12),
          child: TextButton(
              onPressed: () async {
                final create = await Get.toNamed('/register/new');
                if(create == true) {
                  await controller.loadHostCharge();
                  Get.snackbar('', '새 충전소가 등록되었습니다.',
                      snackPosition: SnackPosition.BOTTOM);
                }
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
      body: Obx(() {
        if(controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if(controller.hostchargeStation.isEmpty) {
          return const Center(child: Text("등록한 충전소가 없습니다."));
        }
        return SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.loadHostCharge,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                itemCount: controller.hostchargeStation.length,
                itemBuilder: (context, index) {
                  final station = controller.hostchargeStation[index];

                  final raw = (station['status'] ?? '').toString();
                  final statusText = raw == 'available'
                      ? '사용 가능'
                      : raw == 'unavailable'
                      ? '사용 불가'
                      : '알 수 없음';

                  return AddChargeCard(
                      stationName: station['stationName'],
                      stationAddress: station['address'],
                      chargerStat: statusText,
                        onTap: () async {
                        final changed = await Get.toNamed('/detail', arguments: {'station': station});
                        if (changed == true) {
                          controller.loadHostCharge();
                        }
                        }
                        // => Get.toNamed('/detail', arguments: {'station': station, 'isHost': true}),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            )
        );
      })
    );
  }
}