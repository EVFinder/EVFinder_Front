import 'dart:convert';

import 'package:evfinder_front/Controller/addCharge_controller.dart';
import 'package:evfinder_front/Controller/bnb_station_controller.dart';
import 'package:evfinder_front/Controller/changePassword_controller.dart';
import 'package:evfinder_front/Controller/chatbot_controller.dart';
import 'package:evfinder_front/Controller/community_controller.dart';
import 'package:evfinder_front/Controller/charge_detail_controller.dart';
import 'package:evfinder_front/Controller/favorite_station_controller.dart';
import 'package:evfinder_front/Controller/find_password_controller.dart';
import 'package:evfinder_front/Controller/login_controller.dart';
import 'package:evfinder_front/Controller/main_controller.dart';
import 'package:evfinder_front/Controller/map_controller.dart';
import 'package:evfinder_front/Controller/payment_history_controller.dart';
import 'package:evfinder_front/Controller/register_charge_controller.dart';
import 'package:evfinder_front/Controller/reservManagement_controller.dart';
import 'package:evfinder_front/Controller/reserv_controller.dart';
import 'package:evfinder_front/Controller/reserv_user_controller.dart';
import 'package:evfinder_front/Controller/review_detail_controller.dart';
import 'package:evfinder_front/Controller/review_write_controller.dart';
import 'package:evfinder_front/Controller/search_charger_controller.dart';
import 'package:evfinder_front/Controller/setting_controller.dart';
import 'package:evfinder_front/Controller/host_controller.dart';
import 'package:evfinder_front/Controller/signup_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/camera_controller.dart';
import 'Controller/permission_controller.dart';
import 'Controller/profile_controller.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화
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

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterNaverMap().init(
    clientId: 'qe05hz13nm',
    onAuthFailed: (ex) => switch (ex) {
      NQuotaExceededException(:final message) => print("사용량 초과 (message: $message)"),
      NUnauthorizedClientException() || NClientUnspecifiedException() || NAnotherAuthFailedException() => print("인증 실패: $ex"),
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController());
    Get.put(CameraController());

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var permissionController = Get.find<PermissionController>();
      permissionController.permissionCheck();
    });

    return FutureBuilder<String>(
      future: checkAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중일 때 보여줄 화면
          return MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFF10B981),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'EVFinder',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  ],
                ),
              ),
            ),
          );
        }

        // 자동 로그인 체크 완료 후 실제 앱 실행
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
          initialRoute: snapshot.data ?? AppRoute.login,
        );
      },
    );
  }
}
