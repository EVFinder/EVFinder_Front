import 'package:evfinder_front/View/favortie_station_view.dart';
import 'package:evfinder_front/View/login_view.dart';
import 'package:evfinder_front/View/main_view.dart';
import 'package:get/get.dart';

import '../../View/signup_view.dart';

part 'app_route.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoute.main, page: () => const MainView()),
    GetPage(name: AppRoute.login, page: () => const LoginView()),
    GetPage(name: AppRoute.favorite, page: () => const FavoriteStationView()),
    GetPage(name: AppRoute.profile, page: () => const ProfileView()),
    GetPage(name: AppRoute.signup, page: () => const SignupView()),
  ];
}
