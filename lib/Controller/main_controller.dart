import 'dart:collection';

import 'package:evfinder_front/View/profile_view.dart';
import 'package:evfinder_front/View/host_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../View/map_view.dart';
import '../View/favortie_station_view.dart';

class MainController extends GetxController {
  RxInt selectedIndex = 1.obs;
  List<Widget> pages = <Widget>[FavoriteStationView(), MapView(), HostView(), ProfileView()];


  void setView(int index) {
    selectedIndex.value = index;
  }
}