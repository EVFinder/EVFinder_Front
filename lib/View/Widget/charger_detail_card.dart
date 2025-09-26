import 'package:evfinder_front/Controller/favorite_station_controller.dart';
import 'package:evfinder_front/Model/ev_charger_detail.dart';
import 'package:evfinder_front/Service/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../Controller/map_controller.dart';
import '../../Model/ev_charger.dart';
import '../../Util/charger_status.dart';
import '../Navigation/navigation_controller.dart';
import '../Navigation/navigation_screen.dart';

class ChargerDetailCard extends GetView<MapController> {
  const ChargerDetailCard({
    super.key,
    required this.charger,
    // required this.isFavorite,
  });

  final EvCharger charger;

  // final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteStationController>();
    // 확장 상태를 관리하는 RxBool
    final RxBool isExpanded = false.obs;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final isFavorite = favoriteController.favoriteStations.any((station) => station['id'] == charger.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // 애니메이션 지속시간
          curve: Curves.easeInOut,
          // 애니메이션 커브
          height: isExpanded.value
              ? 250 +
                    (charger.evchargerDetail.length * 70.0) // 확장된 높이 (각 아이템당 60px)
              : 250,
          // 기본 높이
          width: MediaQuery.of(context).size.width - 25,
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 이름, 주소, 즐겨찾기 버튼
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                            charger.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.toNamed('/detail/new'); //충전소 등록 페이지로 이동해야 함
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('상세 보기', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  NavigationController navigationController = Get.find<NavigationController>();

                                  // 현재 위치 확인
                                  if (navigationController.currentLocation.value == null) {
                                    // 위치 권한 요청 및 현재 위치 가져오기
                                    Get.dialog(
                                      Center(
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 16),
                                                Text('현재 위치를 확인하는 중...'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      barrierDismissible: false,
                                    );

                                    await navigationController.getCurrentLocation();
                                    Get.back(); // 위치 확인 다이얼로그 닫기

                                    if (navigationController.currentLocation.value == null) {
                                      Get.snackbar(
                                        '위치 오류',
                                        '현재 위치를 확인할 수 없습니다. 위치 서비스를 켜주세요.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                  }

                                  // 경로 계산 다이얼로그
                                  Get.dialog(
                                    Center(
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text('경로를 계산하는 중...'),
                                              SizedBox(height: 8),
                                              Text(
                                                '목적지: ${charger.name ?? "충전소"}',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  // 네비게이션 시작
                                  await navigationController.startNavigation(charger.lat, charger.lon);

                                  Get.back(); // 로딩 다이얼로그 닫기

                                  // 성공 메시지
                                  Get.snackbar(
                                    '네비게이션 시작',
                                    '${charger.name ?? "충전소"}로 안내를 시작합니다',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 2),
                                  );

                                  // 네비게이션 화면으로 이동
                                  Get.to(() => NavigationScreen());

                                } catch (e) {
                                  Get.back(); // 로딩 다이얼로그 닫기 (혹시 열려있다면)

                                  String errorMessage = '네비게이션을 시작할 수 없습니다';
                                  if (e.toString().contains('location')) {
                                    errorMessage = '위치 서비스를 사용할 수 없습니다';
                                  } else if (e.toString().contains('network')) {
                                    errorMessage = '네트워크 연결을 확인해주세요';
                                  } else if (e.toString().contains('route')) {
                                    errorMessage = '경로를 찾을 수 없습니다';
                                  }

                                  Get.snackbar(
                                    '오류',
                                    errorMessage,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 3),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: const StadiumBorder(),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.navigation, size: 16),
                                  SizedBox(width: 4),
                                  Text('길찾기', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                            charger.addr,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isFavorite) {
                          await favoriteController.removeFavorite(charger.id);
                        } else {
                          await favoriteController.addFavorite(charger);
                        }
                      },
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: Colors.yellow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 하단 상태
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 20, right: 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value; // 상태 토글
                              },
                              child: Text(isExpanded.value ? "접기" : "더보기"),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${charger.evchargerDetail.where((detail) => detail.status == '2').length}", style: const TextStyle(fontSize: 20, color: Colors.green)),
                              const Text("/"),
                              Text("${charger.evchargerDetail.length}", style: const TextStyle(fontSize: 20, color: Colors.blue)),
                            ],
                          ),
                          const Text("충전가능", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 확장된 상태일 때 보여줄 충전소 리스트
              if (isExpanded.value) ...[
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: charger.evchargerDetail.length,
                      itemBuilder: (context, index) {
                        final detail = charger.evchargerDetail[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(radius: 6, backgroundColor: getStatusColor(int.parse(detail.status))),
                          title: Text('충전기 ${index + 1}', style: const TextStyle(fontSize: 14)),
                          subtitle: Text('${detail.type} | ${detail.powerType}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Text(
                            getStatusLabel(int.parse(detail.status)),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: getStatusColor(int.parse(detail.status))),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
