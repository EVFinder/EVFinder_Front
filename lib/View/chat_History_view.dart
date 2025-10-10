import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Controller/chatbot_controller.dart';

class ChatHistoryView extends StatelessWidget {
  final List<ConversationMeta> items;
  final void Function(ConversationMeta meta) onTap;
  final Future<void> Function(ConversationMeta meta)? onDelete;

  const ChatHistoryView({
    super.key,
    required this.items,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy.MM.dd');

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text('채팅 기록'), backgroundColor: Colors.white,),
      body: items.isEmpty
          ? const Center(child: Text('저장된 대화가 없습니다.'))
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final meta = items[i];
          final title = meta.title.isEmpty ? '(제목 없음)' : meta.title;
          final date = fmt.format(meta.createdAt);

          final tile = ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            subtitle: Text(date, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            onTap: () => onTap(meta),
          );

          if (onDelete == null) return tile;

          return Dismissible(
            key: ValueKey(meta.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFEF4444),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onDelete!(meta),
            child: tile,
          );
        },
      ),
    );
  }
}
