import 'package:evfinder_front/Controller/search_charger_controller.dart';
import 'package:evfinder_front/Service/weather_service.dart';
import 'package:evfinder_front/View/Widget/weather_button.dart';
import 'package:evfinder_front/View/search_charger_view.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/map_controller.dart';
import '../Model/search_chargers.dart';
import '../Model/weather.dart';
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
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            SizedBox(height: 20),
            Text('현재 위치를 확인하고 있습니다...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('잠시만 기다려주세요', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                // 🔥 메모리에 저장된 카메라 위치 사용
                target: NLatLng(controller.currentCameraLat.value, controller.currentCameraLng.value),
                zoom: controller.currentZoom.value,
              ),
            ),
            onMapReady: (mController) async {
              await controller.onMapReady(context, mController);
            },
            // 카메라 이동이 완료되었을 때
            onCameraChange: (NCameraUpdateReason reason, bool animated) {
              print('카메라 이동 중: $reason');

              // 🔥 사용자 제스처(드래그, 핀치 줌 등)인지 확인
              if (reason == NCameraUpdateReason.gesture) {
                controller.isUserGesture.value = true;
              } else {
                // 프로그래밍적 이동(검색, 위치 이동 등)
                controller.isUserGesture.value = false;
              }
            },
            onCameraIdle: () async {
              controller.onCameraIdle();
            },
            // 지도 클릭 시
            // onMapTapped: (NPoint point, NLatLng latLng) {
            //   print('지도 클릭 위치: ${latLng.latitude}, ${latLng.longitude}');
            //   controller.onMapTapped(latLng.latitude, latLng.longitude);
            // },
          ),
          // Positioned(
          //   bottom: Get.size.height * 0.05,
          //   right: Get.size.width * 0.1,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       WeatherService.searchUseKeyword(controller.currentCameraLat.value, controller.currentCameraLng.value);
          //     },
          //     backgroundColor: Colors.white,
          //     child: Image.asset('assets/icon/weather/weather_icon_basic_24px.png', color: Colors.blue),
          //   ),
          // ),
          Positioned(
            bottom: Get.size.height * 0.05,
            right: Get.size.width * 0.05,
            child: FutureBuilder<Weather>(
              future: controller.fetchWeather(controller.currentCameraLat.value, controller.currentCameraLng.value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Icon(Icons.error_outline, color: Colors.red, size: 24),
                  );
                }

                if (snapshot.hasData) {
                  final weather = snapshot.data!;
                  return WeatherButton(weather: weather.main, address: controller.address.value, temperature: weather.temperature, humidity: weather.humidity);
                }

                return SizedBox.shrink();
              },
            ),
          ),

          controller.cameraMoved.value
              ? Positioned(
                  top: Get.size.height * 0.12,
                  right: Get.size.width * 0.2,
                  child: SizedBox(
                    width: Get.size.width * 0.6,
                    height: Get.size.width * 0.12,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        controller.refreshCurrentLocation(context);
                      },
                      backgroundColor: Colors.white,
                      label: Text("현재 위치에서 충전소 새로고침"),
                      icon: Icon(Icons.refresh_outlined),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Positioned(
            top: -20,
            child: SearchAppbarWidget(
              topPadding: 60,
              onTap: () async {
                controller.boxController.closeBox();
                final SearchChargers result = await Navigator.push(context, MaterialPageRoute(builder: (_) => SearchChargerView(searchType: SearchType.map)));
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
                        child: SlidingupPanelWidget(chargers: controller.chargers, nMapController: controller.nMapController, boxController: controller.boxController),
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
