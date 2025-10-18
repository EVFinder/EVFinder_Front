import 'dart:collection';

import 'package:evfinder_front/View/Main%20Page/Community/community_view.dart';
import 'package:evfinder_front/View/Main%20Page/Profile/profile_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/host_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../View/Main Page/Map/map_view.dart';
import '../../View/Main Page/Favorite/favortie_station_view.dart';

class MainController extends GetxController {
  RxInt selectedIndex = 2.obs;
  List<Widget> pages = <Widget>[CommunityView(),FavoriteStationView(), MapView(), HostView(), ProfileView()];


  void setView(int index) {
    selectedIndex.value = index;
  }
}