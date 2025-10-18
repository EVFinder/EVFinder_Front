import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeatherButton extends StatelessWidget {
  const WeatherButton({super.key, required this.weather, required this.address, required this.temperature, required this.humidity});

  final String weather;
  final String address;
  final double temperature;
  final int humidity;

  @override
  Widget build(BuildContext context) {
    RxBool isExpanded = false.obs;
    RxBool showContent = false.obs; // 🎯 내용 표시 제어

    return Obx(() {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isExpanded.value ? Get.size.width * 0.8 : Get.size.width * 0.16,
        height: isExpanded.value ? Get.size.height * 0.08 : Get.size.height * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
        ),
        onEnd: () {
          // 🎯 애니메이션 완료 후 내용 표시/숨김
          if (isExpanded.value) {
            showContent.value = true;
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                if (isExpanded.value) {
                  // 축소할 때는 내용을 먼저 숨김
                  showContent.value = false;
                  Future.delayed(Duration(milliseconds: 50), () {
                    isExpanded.value = false;
                  });
                } else {
                  // 확장할 때
                  isExpanded.value = true;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: isExpanded.value ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (weather == "Thunderstorm") Image.asset('assets/icon/weather/weather_thunderstorm.png', color: Colors.yellow, width: 30, height: 30),
                        if (weather == "Rain" || weather == "Drizzle") Image.asset('assets/icon/weather/weather_rain.png', color: Colors.blue, width: 30, height: 30),
                        if (weather == "Snow") Image.asset('assets/icon/weather/weather_snow.png', color: Colors.blue, width: 30, height: 30),
                        if (weather == "Clear") Image.asset('assets/icon/weather/weather_clear.png', color: Colors.lightBlueAccent, width: 30, height: 30),
                        if (weather == "Clouds") Image.asset('assets/icon/weather/weather_cloud.png', color: Colors.grey, width: 30, height: 30),
                        if (weather == "Atmosphere") Image.asset('assets/icon/weather/weather_atmosphere.png', color: Colors.grey, width: 30, height: 30),
                      ],
                    ),
                    if (showContent.value) ...[
                      // 🎯 showContent로 제어
                      SizedBox(width: 5),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address,
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  '온도: $temperature°C',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '습도: $humidity%',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
