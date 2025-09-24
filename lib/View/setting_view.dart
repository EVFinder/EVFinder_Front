import 'package:evfinder_front/Controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  static String route = '/setting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Settnig View")));
  }
}
