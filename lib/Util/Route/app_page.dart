import 'dart:collection';
import 'package:evfinder_front/Controller/register_charge_controller.dart';
import 'package:evfinder_front/Controller/review_write_controller.dart';
import 'package:evfinder_front/View/add_charge_view.dart';
import 'package:evfinder_front/View/add_post_view.dart';
import 'package:evfinder_front/View/bnb_station_view.dart';
import 'package:evfinder_front/View/charge_detail_view.dart';
import 'package:evfinder_front/View/chatbot_view.dart';
import 'package:evfinder_front/View/community_view.dart';
import 'package:evfinder_front/View/edit_post_view.dart';
import 'package:evfinder_front/View/favortie_station_view.dart';
import 'package:evfinder_front/View/login_view.dart';
import 'package:evfinder_front/View/main_view.dart';
import 'package:evfinder_front/View/manage_category_view.dart';
import 'package:evfinder_front/View/map_view.dart';
import 'package:evfinder_front/View/post_detail_view.dart';
import 'package:evfinder_front/View/register_charge_view.dart';
import 'package:evfinder_front/View/reserv_management_view.dart';
import 'package:evfinder_front/View/reserv_user_view.dart';
import 'package:evfinder_front/View/reserv_view.dart';
import 'package:evfinder_front/View/review_detail_view.dart';
import 'package:evfinder_front/View/setting_view.dart';
import 'package:evfinder_front/View/profile_view.dart';
import 'package:evfinder_front/View/change_password.dart';
import 'package:evfinder_front/View/host_view.dart';
import 'package:get/get.dart';
import '../../View/review_write_view.dart';
import '../../View/signup_view.dart';

part 'app_route.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoute.main, page: () => const MainView()),
    GetPage(name: AppRoute.login, page: () => const LoginView()),
    GetPage(name: AppRoute.favorite, page: () => const FavoriteStationView()),
    GetPage(name: AppRoute.profile, page: () => const ProfileView()),
    GetPage(name: AppRoute.signup, page: () => const SignupView()),
    GetPage(name: AppRoute.map, page: () => const MapView()),
    GetPage(name: AppRoute.setting, page: () => const SettingView()),
    GetPage(name: AppRoute.password, page: () => const ChangePasswordView()),
    GetPage(name: AppRoute.host, page: () => const HostView()),
    GetPage(name: AppRoute.addcharge, page: () => const AddChargeView()),
    GetPage(name: AppRoute.management, page: () => const ReservManagementView()),
    GetPage(name: AppRoute.register, page: () => const RegisterChargeView()),
    GetPage(name: AppRoute.reserv, page: () => const ReservView()),
    GetPage(name: AppRoute.detail, page: () => const ChargeDetailView()),
    GetPage(name: AppRoute.bnbcharge, page: () => const BnbStationView()),
    GetPage(name: AppRoute.community, page: () => CommunityView()),
    GetPage(name: AppRoute.reviewWrite, page: () => const ReviewWriteView()),
    GetPage(name: AppRoute.reviewdetail, page: () => const ReviewDetailView()),
    GetPage(name: AppRoute.community, page: () => CommunityView()),
    GetPage(name: AppRoute.addpost, page: () => AddPostView()),
    GetPage(name: AppRoute.reservUser, page: () => const ReservUserView()),
    GetPage(name: AppRoute.postdetail, page: () => const PostDetailView()),
    GetPage(name: AppRoute.editpost, page: () => const EditPostView()),
    GetPage(name: AppRoute.managecategory, page: () => ManageCategoryView()),
    GetPage(name: AppRoute.chatbot, page: () => const ChatbotView())
  ];
}
