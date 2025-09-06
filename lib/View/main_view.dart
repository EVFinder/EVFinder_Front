import 'package:evfinder_front/View/map_view.dart';
import 'package:evfinder_front/View/setting_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Controller/main_controller.dart';
import '../Util/Route/app_page.dart';
import 'favortie_station_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static String route = '/main';

  @override
  Widget build(BuildContext context) {
    // , ProfileView()
    List<Widget> pages = <Widget>[FavoriteStationView(), MapView()];
    return Obx(
      () => Scaffold(
        appBar: controller.selectedIndex.value == 2
            ? AppBar(
                title: Text("EVFinder"),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed(AppRoute.setting);
                    },
                    icon: Icon(Icons.settings),
                  ),
                ],
              )
            : null,
        //Navigation Bar
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 10,
            child: Padding(
              padding: const EdgeInsets.only(right: 30, left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      controller.selectedIndex.value = 0;
                    },
                    icon: Icon(Icons.star, size: 25),
                    color: controller.selectedIndex.value == 0 ? Colors.green : Colors.black12,
                  ),
                  IconButton(
                    onPressed: () {
                      controller.selectedIndex.value = 1;
                    },
                    icon: Icon(Icons.explore, size: 25),
                    color: controller.selectedIndex.value == 1 ? Colors.green : Colors.black12,
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     selectedIndex.value = 2;
                  //   },
                  //   icon: Icon(Icons.person, size: 25),
                  //   color: selectedIndex.value == 2 ? Colors.green : Colors.black12,
                  // ),
                ],
              ),
            ),
          ),
        ),

        // 가운데 동그란 버튼
        // floatingActionButton: SizedBox(
        //   height: 80,
        //   width: 80,
        //   child: FloatingActionButton(
        //     clipBehavior: Clip.none,
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        //     onPressed: () {
        //       setState(() {
        //         selectedIndex = 1;
        //       });
        //     },
        //     backgroundColor: selectedIndex == 1 ? Colors.green : Colors.grey,
        //     child: Icon(Icons.map, size: 35),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: pages[controller.selectedIndex.value],
      ),
    );
  }
}
