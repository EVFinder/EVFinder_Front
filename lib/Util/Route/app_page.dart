import 'package:evfinder_front/View/login_view.dart';
import 'package:evfinder_front/View/main_view.dart';
import 'package:get/get.dart';

part 'app_route.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoute.main, page: () => const MainView()),
    GetPage(name: AppRoute.login, page: () => const LoginView()),
  ];
}
