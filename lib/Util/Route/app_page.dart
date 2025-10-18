import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/add_charge_view.dart';
import 'package:evfinder_front/View/Main%20Page/Community/add_post_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/bnb_station_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/charge_detail_view.dart';
import 'package:evfinder_front/View/Main%20Page/Community/community_view.dart';
import 'package:evfinder_front/View/Main%20Page/Community/edit_post_view.dart';
import 'package:evfinder_front/View/Main%20Page/Favorite/favortie_station_view.dart';
import 'package:evfinder_front/View/Auth/find_password_view.dart';
import 'package:evfinder_front/View/Main%20Page/main_view.dart';
import 'package:evfinder_front/View/Main%20Page/Community/manage_category_view.dart';
import 'package:evfinder_front/View/Main%20Page/Map/map_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Pay/payment_history_view.dart';
import 'package:evfinder_front/View/Main%20Page/Community/post_detail_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/register_charge_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Reserve/reserv_management_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Reserve/reserv_user_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Reserve/reserv_view.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Review/review_detail_view.dart';
import 'package:evfinder_front/View/Main%20Page/Profile/setting_view.dart';
import 'package:evfinder_front/View/Main%20Page/Profile/profile_view.dart';
import 'package:evfinder_front/View/Auth/change_password.dart';
import 'package:evfinder_front/View/Main%20Page/ChargerBnB/Charger/host_view.dart';
import 'package:get/get.dart';
import '../../View/Auth/login_view.dart';
import '../../View/Main Page/ChargerBnB/Review/review_write_view.dart';
import '../../View/Auth/signup_view.dart';
import '../../View/Main Page/Profile/Chatbot/chatbot_view.dart';

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
    GetPage(name: AppRoute.chatbot, page: () => const ChatbotView()),
    GetPage(name: AppRoute.find, page: () => const FindPasswordView()),
    GetPage(name: AppRoute.paymentHistory, page: () => const PaymentHistoryView()),
  ];
}
