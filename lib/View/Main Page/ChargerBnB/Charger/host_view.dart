import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/bnb_station_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Reserve/reserv_management_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controller/MainPage/ChargerBnB/Charger/host_controller.dart';
import 'add_charge_view.dart';

class HostView extends GetView<HostController> {
  const HostView({super.key});
  static String route = "/host";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.ev_station), text: '충전소 목록',),
              Tab(icon: Icon(Icons.add_location_alt), text: '충전소 등록')
        ],
        ),
      ),
    body: const TabBarView(
    children: [
      BnbStationView(),
      AddChargeView(),
    ],
    ),
    ),
    );
  }
}