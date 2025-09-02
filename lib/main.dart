import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Util/Route/app_page.dart';
import 'Constants/constantstest.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // title: AppConstants.appName,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
