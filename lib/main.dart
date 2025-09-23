import 'package:evfinder_front/Controller/addCharge_controller.dart';
import 'package:evfinder_front/Controller/charge_datail_controller.dart';
import 'package:evfinder_front/Controller/favorite_station_controller.dart';
import 'package:evfinder_front/Controller/login_controller.dart';
import 'package:evfinder_front/Controller/main_controller.dart';
import 'package:evfinder_front/Controller/map_controller.dart';
import 'package:evfinder_front/Controller/register_charge_controller.dart';
import 'package:evfinder_front/Controller/reservManagement_controller.dart';
import 'package:evfinder_front/Controller/reserv_controller.dart';
import 'package:evfinder_front/Controller/setting_controller.dart';
import 'package:evfinder_front/Controller/host_controller.dart';
import 'package:evfinder_front/Controller/signup_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/camera_controller.dart';
import 'Controller/permission_controller.dart';
import 'Controller/profile_controller.dart';
import 'Util/Route/app_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterNaverMap().init(
    clientId: 'qe05hz13nm',
    onAuthFailed: (ex) => switch (ex) {
      NQuotaExceededException(:final message) => print(
        "사용량 초과 (message: $message)",
      ),
      NUnauthorizedClientException() ||
      NClientUnspecifiedException() ||
      NAnotherAuthFailedException() => print("인증 실패: $ex"),
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    return jwt != null; // JWT가 있으면 자동 로그인
  }

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController());
    Get.put(CameraController());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var permissionController = Get.find<PermissionController>();
      permissionController.permissionCheck();
      // permissionController.dispose();
    });
    return GetMaterialApp(

      theme: ThemeData(
        fontFamily: 'neo',
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(LoginController());
        Get.lazyPut(() => SignupController());
        Get.lazyPut(() => MainController());
        Get.lazyPut(() => MapController());
        Get.lazyPut(() => ProfileController());
        Get.lazyPut(() => FavoriteStationController());
        Get.lazyPut(() => SettingController());
        Get.lazyPut(() => HostController());
        Get.lazyPut(() => AddChargeController());
        Get.lazyPut(() => ReservManagementController());
        Get.lazyPut(() => RegisterChargeController());
        Get.lazyPut(() => ReservController());
        Get.lazyPut(() => ChargeDatailController());
        // Get.put(AuthController());
        // Get.lazyPut(() => ProfileController(), fenix: true);
      }),
      getPages: AppPages.pages,
      initialRoute: AppRoute.login,
    );
  }
}

