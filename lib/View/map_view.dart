import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  static String route = '/map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("map view")));
  }
}
