import 'dart:ffi';

import 'package:evfinder_front/Controller/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../Controller/favorite_station_controller.dart';
import '../../Model/ev_charger.dart';
import '../../Service/favorite_service.dart';
import 'charger_detail_card.dart';
import 'listtile_chargerinfo_widget.dart';

class SlidingupPanelWidget extends StatelessWidget {
  const SlidingupPanelWidget({super.key, required this.chargers, required this.nMapController, required this.boxController});

  final List<EvCharger> chargers;
  final NaverMapController nMapController;
  final BoxController boxController;
  static CameraController cameraController = CameraController();

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteStationController>();

    //슬라이딩 박스 위젯
    return SlidingBox(
      controller: boxController,
      collapsed: true,
      minHeight: 30,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.53,
        child: ListView.separated(
          itemCount: chargers.length,
          itemBuilder: (context, int index) {
            return ListtileChargerinfoWidget(
              isCancelIconExist: false,
              addr: chargers[index].addr,
              name: chargers[index].name,
              // stat: widget.chargers[index].evchargerDetail[0].status,
              stat: chargers[index].evchargerDetail.where((detail) => detail.status == '2').isNotEmpty ? 2 : 1,
              onTap: () async {
                boxController.closeBox();
                cameraController.moveCameraPosition(chargers[index].lat, chargers[index].lon, nMapController);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return ChargerDetailCard(
                          charger: chargers[index],
                          // isFavorite: false, // 또는 적절한 값
                          // uid: uid,
                        );
                      },
                    );
                  },
                );
                // final statIds = await FavoriteService.getFavoriteStatIds('test_user');
                // final isFavorite = statIds.contains(chargers[index].id);
                // showModalBottomSheet(
                //   context: context,
                //   builder: (_) => ChargerDetailCard(charger: widget.chargers[index], isFavorite: isFavorite, uid: _uid),
                // );
              },
              isStatChip: true,
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
        ),
      ),
    );
  }
}
