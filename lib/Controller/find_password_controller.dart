import 'dart:convert';
import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FindPasswordController extends GetxController {
  final isLoading = false.obs;
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> findPW(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('', '이메일을 입력하세요');
      return;
    }

    try {
      isLoading.value = true;

      final resp = await http.post(Uri.parse('${ApiConstants.authApiBaseUrl}/reset-password'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email}));

      final bodyString = utf8.decode(resp.bodyBytes);
      debugPrint('서버 응답 코드: ${resp.statusCode}');
      debugPrint('서버 응답 내용: $bodyString');

      if (resp.statusCode == 200) {
        // 서버가 {"resetLink": "..."} 혹은 그냥 문자열을 반환할 수 있으므로 방어적 파싱
        String link;
        try {
          final m = jsonDecode(bodyString);
          link = (m['resetLink'] ?? '').toString();
          if (link.isEmpty) link = bodyString.trim();
        } catch (_) {
          link = bodyString.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('재설정 링크가 준비됐어요')));
        _showResetLinkSheet(context, link, email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패 (${resp.statusCode})')));
        // ❌ 여기서 페이지를 닫아버리면 UX가 불편합니다. Get.back() 제거!
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 중 오류: $e')));
    } finally {
      isLoading.value = false;
    }
  }
}

void _showResetLinkSheet(BuildContext context, String link, String email) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      final inset = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + inset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('재설정 링크가 준비됐어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            Text('보낸 이메일: $email', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
              child: SelectableText(link, maxLines: 2, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(icon: const Icon(Icons.open_in_new), label: const Text('브라우저로 열기'), onPressed: () => _safeLaunch(link)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('링크 복사'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: link));
                      Get.snackbar('', '클립보드에 복사되었습니다.');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('닫기')),
          ],
        ),
      );
    },
  );
}

Future<void> _safeLaunch(String link) async {
  try {
    final uri = Uri.parse(link);
    // 실행 가능 여부 체크
    final can = await canLaunchUrl(uri);
    if (!can) {
      await Clipboard.setData(ClipboardData(text: link));
      Get.snackbar('링크 복사됨', '브라우저에 붙여넣어 열어주세요.');
      return;
    }
    // 외부 브라우저로 열기
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw '링크 열기에 실패했습니다.';
    }
  } catch (e) {
    await Clipboard.setData(ClipboardData(text: link));
    Get.snackbar('오류', '링크를 복사해두었어요: $e');
  }
}
