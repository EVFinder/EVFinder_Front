import 'package:evfinder_front/View/search_charger_view.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/map_controller.dart';
import '../Model/search_chargers.dart';
import 'Widget/search_appbar_widget.dart';
import 'Widget/sliding_pannel_widget.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  static String route = '/map';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<void>(
        future: controller.initializeLocation(),
        builder: (context, snapshot) {
          // 위치 정보를 가져오는 동안 로딩 화면
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          // 위치 정보 가져오기 완료 후 지도 렌더링
          return _buildMapScreen(context);
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              '현재 위치를 확인하고 있습니다...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '잠시만 기다려주세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapScreen(BuildContext context) {
    return Obx(
          () => Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: controller.userPosition.value != null
                    ? NLatLng(
                  controller.userPosition.value!.latitude,
                  controller.userPosition.value!.longitude,
                )
                    : const NLatLng(37.5665, 126.9780),
                zoom: 15,
              ),
            ),
            onMapReady: (mController) async {
              controller.nMapController = mController;
              await controller.fetchMyChargers(context, null);
              controller.isMapReady.value = true;
            },
          ),
          Positioned(
            top: -20,
            child: SearchAppbarWidget(
              onTap: () async {
                controller.boxController.closeBox();
                final SearchChargers result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchChargerView()),
                );
                await controller.fetchMyChargers(context, result);
              },
            ),
          ),
          Obx(() {
            return controller.isMapReady.value
                ? GetBuilder<MapController>(
              builder: (controller) {
                return Positioned(
                  bottom: 0,
                  child: SlidingupPanelWidget(
                    chargers: controller.chargers,
                    nMapController: controller.nMapController,
                    boxController: controller.boxController,
                  ),
                );
              },
            )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
