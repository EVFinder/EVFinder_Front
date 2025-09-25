import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/search_charger_controller.dart';
import '../Model/ev_charger.dart';
import '../Service/ev_charger_service.dart';
import '../Service/marker_service.dart';
import 'Widget/listtile_chargerinfo_widget.dart';

class SearchChargerView extends GetView<SearchChargerController> {
  final SearchType searchType;
  const SearchChargerView({ //searchtype도 전달 받음+
    super.key,
    required this.searchType,
});

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) { //컨트롤러로 타입 전달
      controller.setSearchType(searchType);
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: TextFormField(
                onFieldSubmitted: (input) async {
                  controller.searchList(input);
                },
                controller: controller.tController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.searchList(controller.tController.text);
                    },
                    icon: Icon(Icons.search),
                  ),
                  hintText: '충전소 검색',
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),

              // ListTile(
              //   leading: IconButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     icon: Icon(Icons.arrow_back),
              //   ),
              //   trailing: IconButton(
              //     onPressed: () {
              //       setState(() {
              //         searchList(tController.text);
              //       });
              //     },
              //     icon: Icon(Icons.search),
              //   ),
              //   title: TextField(
              //     onSubmitted: (input) async {
              //       searchList(input);
              //     },
              //     controller: tController,
              //     decoration: InputDecoration(hintText: "충전소 검색", border: InputBorder.none),
              //   ),
              // ),
            ),
            Obx(
                  () => SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: ListView.separated(
                  itemCount: controller.activeList.length,
                  // primary: false,
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListtileChargerinfoWidget(
                      isCancelIconExist: false,
                      name: controller.activeList[index].placeName,
                      addr: controller.activeList[index].addressName,
                      stat: 0,
                      onTap: () async {
                        // controller.selectSearchResult(index);
                        Navigator.pop(context, controller.activeList[index]);
                      },
                      isStatChip: false,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
