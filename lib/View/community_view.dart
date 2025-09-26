import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../Controller/community_controller.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});

  static String route = '/community';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("커뮤니티"),),
        body: Center(child: Text("community")));
  }
}
