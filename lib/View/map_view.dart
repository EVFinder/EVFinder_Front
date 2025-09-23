import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/map_controller.dart';
import 'Widget/sliding_pannel_widget.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  static String route = '/map';

  @override
  Widget build(BuildContext context) {
    // 화면이 빌드될 때 한 번만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLocationLoaded.value) {
        controller.initializeLocation();
      }
    });
    return Obx(
      () => SafeArea(
        child: Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: controller.userPosition.value != null
                      ? NLatLng(controller.userPosition.value!.latitude, controller.userPosition.value!.longitude)
                      : const NLatLng(37.5665, 126.9780),
                  zoom: 15,
                ),
              ),
              onMapReady: (mController) async {
                controller.nMapController = mController;
                await controller.fetchMyChargers(context, null);
                controller.isMapReady.value = true;
                // controller.loadMarkers(context, controller.chargers);
                // if (controller.isMapReady.value == false) {
                //   await controller.fetchMyChargers(context, null);
                //   controller.nMapController = mController;
                //   controller.isMapReady.value = true;
                //   controller.loadMarkers(context, controller.chargers); // 서버에서 충전소 받아와서 마커 표시
                // }
              },
            ),
            // Positioned(
            //   top: -20,
            //   child: SearchAppbarWidget(
            //     onTap: () async {
            //       final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => SearchChargerView()));
            //       await fetchMyChargers(context, result);
            //     },
            //   ),
            // ),
            controller.isMapReady.value
                ? Positioned(
                    bottom: 0,
                    // child: SizedBox.shrink(),
                    child: SlidingupPanelWidget(chargers: controller.chargers, nMapController: controller.nMapController, boxController: controller.boxController),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
