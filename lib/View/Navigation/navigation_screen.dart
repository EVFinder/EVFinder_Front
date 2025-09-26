import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';
import 'navigation_map_widget.dart';

class NavigationScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());

  NavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('경로 데이터를 불러오는 중...'),
                SizedBox(height: 8),
                Text(
                  controller.navigationStatus.value,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 상단 네비게이션 정보
            _buildNavigationInfo(),

            // 지도 영역
            Expanded(
              child: _buildMap(),
            ),

            // 하단 컨트롤
            _buildBottomControls(),
          ],
        );
      }),
    );
  }

  Widget _buildNavigationInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue,
      child: SafeArea(
        child: Obx(() => Column(
          children: [
            Text(
              controller.currentInstruction.value.isEmpty
                  ? '경로 안내를 시작합니다'
                  : controller.currentInstruction.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '다음: ${controller.formattedDistance}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '총 거리: ${controller.formattedTotalDistance}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '예상 시간: ${controller.formattedTotalTime}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      print('=== NavigationScreen _buildMap 디버깅 ===');
      print('navigationData.value: ${controller.navigationData.value}');
      print('currentLocation.value: ${controller.currentLocation.value}');
      print('isNavigating.value: ${controller.isNavigating.value}');
      print('navigationStatus.value: ${controller.navigationStatus.value}');

      if (controller.navigationData.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('경로 데이터를 불러오는 중...'),
              SizedBox(height: 8),
              Text(
                controller.navigationStatus.value,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return NavigationMapWidget(
        navigationData: controller.navigationData.value!,
        currentLocation: controller.currentLocation.value,
      );
    });
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.stopNavigation();
                  Get.back();
                },
                child: Text('네비게이션 중지'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showRouteOptionsDialog();
                },
                child: Text('경로 옵션'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteOptionsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('경로 옵션'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('경로 재계산'),
              onTap: () {
                Get.back();
                controller.recalculateRoute();
              },
            ),
            ListTile(
              leading: Icon(Icons.volume_up),
              title: Text('음성 안내 설정'),
              onTap: () {
                Get.back();
                // 음성 설정 로직
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }
}
