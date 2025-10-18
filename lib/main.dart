import 'dart:convert';

import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Charger/addCharge_controller.dart';
import 'package:evfinder_front/Controller/Auth/changePassword_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Profile/chatbot_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Community/community_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Charger/charge_detail_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Favorite/favorite_station_controller.dart';
import 'package:evfinder_front/Controller/Auth/find_password_controller.dart';
import 'package:evfinder_front/Controller/Auth/login_controller.dart';
import 'package:evfinder_front/Controller/MainPage/main_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Map/map_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Pay/payment_history_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Reserve/reservManagement_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Reserve/reserv_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Reserve/reserv_user_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Review/review_detail_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Map/search_charger_controller.dart';
import 'package:evfinder_front/Controller/MainPage/Profile/setting_controller.dart';
import 'package:evfinder_front/Controller/MainPage/ChargerBnB/Charger/host_controller.dart';
import 'package:evfinder_front/Controller/Auth/signup_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/MainPage/ChargerBnB/Charger/bnb_station_controller.dart';
import 'Controller/MainPage/ChargerBnB/Charger/register_charge_controller.dart';
import 'Controller/MainPage/ChargerBnB/Review/review_write_controller.dart';
import 'Controller/MainPage/camera_controller.dart';
import 'Controller/MainPage/permission_controller.dart';
import 'Controller/MainPage/Profile/profile_controller.dart';
import 'PushNotification.dart';
import 'Util/Route/app_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("Notification Received!");
  }
}

Future<void> setupInteractedMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  Future.delayed(const Duration(seconds: 1), () {
    navigatorKey.currentState!.pushNamed("/message", arguments: message);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PushNotification.init();
  PushNotification.localNotiInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print('Got a message in foreground');
    if (message.notification != null) {
      PushNotification.showSimpleNotification(title: message.notification!.title!, body: message.notification!.body!, payload: payloadData);
    }
  });
  setupInteractedMessage();

  await FlutterNaverMap().init(
    clientId: 'qe05hz13nm',
    onAuthFailed: (ex) => switch (ex) {
      NQuotaExceededException(:final message) => print("사용량 초과 (message: $message)"),
      NUnauthorizedClientException() || NClientUnspecifiedException() || NAnotherAuthFailedException() => print("인증 실패: $ex"),
    },
  );

  // 자동 로그인 체크
  String initialRoute = await checkAutoLogin();

  // 모든 준비 완료 후 스플래시 제거
  FlutterNativeSplash.remove();

  runApp(MyApp(initialRoute: initialRoute)); // ← initialRoute 전달
}

Future<String> checkAutoLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final jwt = prefs.getString('jwt');
  final isAutoLogin = prefs.getBool('isAutoLogin') ?? false;

  if (jwt != null && isAutoLogin) {
    return AppRoute.main;
  } else {
    return AppRoute.login;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute; // ← initialRoute 받기

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController());
    Get.put(CameraController());

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var permissionController = Get.find<PermissionController>();
      permissionController.permissionCheck();
    });

    return GetMaterialApp(
      locale: const Locale("ko", "KR"),
      theme: ThemeData(fontFamily: 'neo'),
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(LoginController());
        Get.lazyPut(() => FavoriteStationController(), fenix: true);
        Get.lazyPut(() => SignupController(), fenix: true);
        Get.lazyPut(() => MainController(), fenix: true);
        Get.lazyPut(() => MapController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
        Get.lazyPut(() => SettingController(), fenix: true);
        Get.lazyPut(() => HostController(), fenix: true);
        Get.lazyPut(() => AddChargeController(), fenix: true);
        Get.lazyPut(() => ReservManagementController(), fenix: true);
        Get.lazyPut(() => RegisterChargeController(), fenix: true);
        Get.lazyPut(() => ReservController(), fenix: true);
        Get.lazyPut(() => SearchChargerController(), fenix: true);
        Get.lazyPut(() => BnbStationController(), fenix: true);
        Get.lazyPut(() => CommunityController(), fenix: true);
        Get.lazyPut(() => ChargeDetailController(), fenix: true);
        Get.lazyPut(() => ReservUserController(), fenix: true);
        Get.lazyPut(() => ReviewWriteController(), fenix: true);
        Get.lazyPut(() => ReviewDetailController(), fenix: true);
        Get.lazyPut(() => ChatbotController(), fenix: true);
        Get.lazyPut(() => ChangePasswordController(), fenix: true);
        Get.lazyPut(() => FindPasswordController(), fenix: true);
        Get.lazyPut(() => PaymentHistoryController(), fenix: true);
      }),
      getPages: AppPages.pages,
      initialRoute: initialRoute, // ← 전달받은 initialRoute 사용
    );
  }
}
