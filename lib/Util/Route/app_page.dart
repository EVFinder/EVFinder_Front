import 'package:evfinder_front/main.dart';
import 'package:get/get.dart';
import '../../View/viewtest.dart';
import '../../Controller/controllertest.dart';

part 'app_route.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => MyApp(),
      binding: BindingsBuilder(() {
        // Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
  ];
}
