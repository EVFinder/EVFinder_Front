import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/chatbot_controller.dart';

const kPrimary = Color(0xFF3B82F6);
const kSurface = Color(0xFFF5F7FB);
const kTextDark = Color(0xFF0F172A);
const kTextSub = Color(0xFF64748B);

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});
  static String route = "/chatbot";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.background : kSurface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text("EV 챗봇", style: TextStyle(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [

            // 메시지 리스트
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  controller: controller.scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final m = controller.messages[index];
                    return _ChatBubble(
                      text: m.text,
                      time: m.time,
                      isMe: m.isMe,
                    );
                  },
                );
              }),
            ),

            // 입력 바
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14, offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.openHistoryPage, // 첨부 기능 예정
                      icon: const Icon(Icons.history),
                      tooltip: "채팅 기록",
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.textCtrl,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: "메시지를 입력하세요",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Obx(() => SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: controller.isloading.value ? null : controller.send,
                        child: controller.isloading.value
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Row(children: [Text("전송", style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(width: 6), Icon(Icons.send_rounded, size: 18)]),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final DateTime time;
  final bool isMe;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = TimeOfDay.fromDateTime(time).format(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    final bg = isMe ? kPrimary : Colors.white;
    final fg = isMe ? Colors.white : kTextDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const _Avatar(),
          if (!isMe) const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),  // 꼬리 느낌
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      text,
                      style: TextStyle(fontSize: 15, height: 1.35, color: fg),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : kTextSub),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe) const _Avatar(isMe: true),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isMe;
  const _Avatar({this.isMe = false});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: isMe ? kPrimary : const Color(0xFF22D3EE),
      child: Icon(
        isMe ? Icons.person : Icons.smart_toy_rounded,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}
