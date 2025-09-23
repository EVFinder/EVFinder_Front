import 'package:evfinder_front/View/reserv_management_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/host_controller.dart';
import '../View/add_charge_view.dart';

class HostView extends GetView<HostController> {
  const HostView({super.key});
  static String route = "/share";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.add_location_alt), text: '충전소 등록'),
              Tab(icon: Icon(Icons.calendar_month), text: '예약 관리',)
        ],
        ),
      ),
    body: const TabBarView(
    children: [
     AddChargeView(),
     ReservManagementView(),
    ],
    ),
    ),
    );
  }
}