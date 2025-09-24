import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/api_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Util/Route/app_page.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // final UserModel _model = UserModel();

  Future<void> success(BuildContext context, String jwt) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("로그인 성공")));
    await Get.offAndToNamed(AppRoute.main);
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  bool _isValidInput(String email, String password) {
    return email.isNotEmpty && password.length >= 6;
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!_isValidInput(email, password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이메일 또는 비밀번호를 확인하세요.")));
      return;
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid!); //uid 저장

      print(prefs.getString("uid"));

      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firebase ID 토큰을 가져오지 못했습니다')));
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.authApiBaseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // if (decoded['success'] == true) {
        final String jwt = decoded['jwt'];
        // final String uid = decoded['uid'];
        // final String email = decoded['email'];
        // final String userName = decoded['userName'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);
        // await prefs.setString('uid', uid); //uid 저장
        // await prefs.setString('email', email);
        // await prefs.setString('name', userName);



        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 성공')));

        success(context, jwt); // 구글 로그인과 동일하게 처리
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('로그인 실패: ${decoded['message']}')),
        //   );
        // }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('서버 오류가 발생했습니다.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패: ${e.toString()}')));
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // final String? idToken = await userCredential.user?.getIdToken();
      final uid = userCredential.user?.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid!);

      // if (idToken == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Firebase ID 토큰을 가져오지 못했습니다')),
      //   );
      //   return;
      // }

      final User? user = userCredential.user;
      if (user != null) {
        final response = await http.post(
          Uri.parse('${ApiConstants.authApiBaseUrl}/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': googleUser.email, 'password': 'GOOGLE_LOGIN_$uid'}), // 구글 로그인 시 비밀번호는 필요 없음
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);

          // if (decoded['success'] == true) {
          final String jwt = decoded['jwt'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', jwt);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google 로그인 성공')));

          success(context, jwt);
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('로그인 실패: ${decoded['message']}')),
          //   );
          // }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('서버 오류 발생')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google 로그인 실패: ${e.toString()}')));
    }
  }

  Future<void> changePassword(BuildContext context, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID 토큰을 가져올 수 없습니다.")));
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.authApiBaseUrl}/changepw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken, 'newPassword': newPassword}),
      );

      final decoded = jsonDecode(response.body);
      if (decoded['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("비밀번호 변경 완료")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: ${decoded['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러 발생: $e")));
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt'); // 저장된 JWT 토큰

      if (jwt == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
        return;
      }

      final response = await http.delete(Uri.parse('${ApiConstants.authApiBaseUrl}/delete'), headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'});

      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        await FirebaseAuth.instance.signOut();
        await prefs.clear(); // 로그인 정보 삭제

        await Get.toNamed(AppRoute.login);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원탈퇴가 완료되었습니다.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: ${decoded['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  void handleGoogleLogin(BuildContext context) async {
    isLoading.value = true; // 먼저 로딩 시작

    try {
      await signInWithGoogle(context); // await 추가
    } finally {
      isLoading.value = false; // 항상 로딩 종료
    }
  }

  void handleLogin(BuildContext context) async {
    isLoading.value = true; // 먼저 로딩 시작

    try {
      await login(context); // await 추가
    } finally {
      isLoading.value = false; // 항상 로딩 종료
    }
  }

  void handleSignup() {
    Get.toNamed(AppRoute.signup);
  }
}
