import 'dart:convert';
import 'package:evfinder_front/Constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../View/chat_History_view.dart'; // 날짜 포맷용

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, DateTime? time}) : time = time ?? DateTime.now();
}

// ⬇️ 대화 메타
class ConversationMeta {
  final String id;
  final String title;
  final DateTime createdAt;

  ConversationMeta({required this.id, required this.title, required this.createdAt});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'createdAt': createdAt.toIso8601String()};

  factory ConversationMeta.fromJson(Map<String, dynamic> j) {
    return ConversationMeta(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class ChatbotController extends GetxController {
  final messages = <ChatMessage>[].obs;

  final uid = ''.obs;
  final name = ''.obs;

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  final isloading = false.obs;

  String _conversationId = '';
  String? _pendingTitle;
  List<ConversationMeta> _convMetas = [];

  String get _metaKey => 'chatbot_conversations_meta_${uid.value}';

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await _loadUserAndMetas();

    // 히스토리에서 진입한 경우(복원 모드)
    final argConvId = (Get.arguments?['conversationId'] ?? '').toString();
    if (argConvId.isNotEmpty) {
      _conversationId = argConvId;
      await loadHistoryAndShow(_conversationId);
    } else {
      // 새 대화 모드
      messages.clear();
      final displayName = name.value.isNotEmpty ? name.value : '고객';
      messages.add(ChatMessage(text: "$displayName님 안녕하세요! 무엇을 도와드릴까요?", isMe: false));
    }
  }

  Future<void> _loadUserAndMetas() async {
    final prefs = await SharedPreferences.getInstance();
    uid.value = prefs.getString('uid') ?? '';
    name.value = prefs.getString('name') ?? '';

    final raw = prefs.getString(_metaKey);
    if (raw != null && raw.isNotEmpty) {
      final List list = jsonDecode(raw) as List;
      _convMetas = list.map((e) => ConversationMeta.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _convMetas = [];
    }
  }

  Future<void> _saveMetas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey, jsonEncode(_convMetas.map((e) => e.toJson()).toList()));
  }

  // --- 전송 ---
  Future<void> send() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty || isloading.value) return;

    // 첫 메시지면 제목 후보로 잠시 보관
    if (_conversationId.isEmpty && (_pendingTitle == null || _pendingTitle!.isEmpty)) {
      _pendingTitle = text;
    }

    messages.add(ChatMessage(text: text, isMe: true));
    textCtrl.clear();
    _scrollToBottom();

    isloading.value = true;
    try {
      final uri = Uri.parse('${ApiConstants.chatbotApiBaseUrl}/ask');
      final resp = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'},
            body: jsonEncode({
              "uid": uid.value,
              "conversationId": _conversationId, // 새 대화면 "" 전달
              "message": text,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200) {
        final data = resp.body.isEmpty ? {} : (jsonDecode(resp.body) as Map<String, dynamic>);
        final reply = (data['answer'] ?? '응답이 비었습니다.').toString();
        final newIdStr = (data['conversationId'] ?? '').toString();

        // 새 ID를 처음 받은 순간 메타 저장
        if (newIdStr.isNotEmpty && _conversationId.isEmpty) {
          _conversationId = newIdStr;

          // 중복 저장 방지
          final exists = _convMetas.any((m) => m.id == _conversationId);
          if (!exists) {
            final title = (_pendingTitle ?? '새 대화').trim();
            _convMetas.insert(0, ConversationMeta(id: _conversationId, title: title, createdAt: DateTime.now()));
            // 최대 100개까지만 보관(선택)
            if (_convMetas.length > 100) _convMetas = _convMetas.take(100).toList();
            await _saveMetas();
          }
        }

        // 이후 응답 표시
        messages.add(ChatMessage(text: reply, isMe: false));
      } else {
        Get.snackbar('요청 실패', '(${resp.statusCode}) ${resp.reasonPhrase ?? ''}', duration: const Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar('네트워크 오류', e.toString(), duration: const Duration(seconds: 2));
    } finally {
      isloading.value = false;
      _pendingTitle = null; // 제목 후보 초기화
      _scrollToBottom();
    }
  }

  // --- 히스토리 불러오기 & 화면 표시 ---
  Future<List<ChatMessage>> fetchHistory(String conversationId) async {
    final uri = Uri.parse(
      '${ApiConstants.chatbotApiBaseUrl}/history'
      '?uid=${Uri.encodeQueryComponent(uid.value)}'
      '&conversationId=${Uri.encodeQueryComponent(conversationId)}',
    );

    final resp = await http.get(uri).timeout(const Duration(seconds: 12));

    if (resp.statusCode == 200) {
      final list = (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();

      final msgs = list.map((e) {
        final role = (e['role'] ?? '').toString().toLowerCase();
        final isUser = role == 'user';
        final content = (e['content'] ?? '').toString();
        final ts = DateTime.tryParse((e['timestamp'] ?? '').toString()) ?? DateTime.now();
        return ChatMessage(text: content, isMe: isUser, time: ts);
      }).toList();

      // 2) 정렬: 시간 ↑, 같은 시간일 땐 user가 먼저
      msgs.sort((a, b) {
        final t = a.time.compareTo(b.time);
        if (t != 0) return t;
        if (a.isMe != b.isMe) return a.isMe ? -1 : 1;
        return 0;
      });

      return msgs;
    }
    throw Exception('히스토리 요청 실패: ${resp.statusCode} ${resp.reasonPhrase ?? ''}');
  }

  Future<void> loadHistoryAndShow(String conversationId) async {
    messages.clear();
    try {
      final hist = await fetchHistory(conversationId);
      if (hist.isEmpty) {
        messages.add(ChatMessage(text: '만료되었거나 비어있는 대화입니다.', isMe: false));
      } else {
        messages.addAll(hist);
      }
    } catch (e) {
      messages.add(ChatMessage(text: '히스토리 불러오기 실패: $e', isMe: false));
    } finally {
      _scrollToBottom();
    }
  }

  // --- 히스토리 리스트로 이동 ---
  void openHistoryPage() {
    Get.to(
      () => ChatHistoryView(
        items: _convMetas,
        onTap: (meta) {
          Get.back();
          _conversationId = meta.id;
          loadHistoryAndShow(meta.id);
        },
        onDelete: (meta) async {
          _convMetas.removeWhere((m) => m.id == meta.id);
          await _saveMetas();
          update();
        },
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!scrollCtrl.hasClients) return;
      scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  void onClose() {
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
