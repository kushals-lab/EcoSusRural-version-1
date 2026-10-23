import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import '../models/chat_conversation.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;
    final conversations = ref.watch(chatConversationsProvider);
    final screenConversations = conversations.isEmpty ? <ChatConversation>[] : conversations;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Messages', style: TextStyle(color: const Color(0xFF2E7D3E), fontWeight: FontWeight.bold, fontSize: 20.sp)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF2E7D3E)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.security_rounded, color: Color(0xFF2E7D3E)), onPressed: () {}),
        ],
      ),
      body: screenConversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 56, color: Color(0xFF2E7D3E)),
                  SizedBox(height: 10.h),
                  Text(tr('noMessages'), style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
                  SizedBox(height: 8.h),
                  Text('End-to-end encrypted', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: screenConversations.length,
              itemBuilder: (context, index) {
                final conversation = screenConversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: const Color(0xFFDCF2C0),
                    child: Text(conversation.participantName.isNotEmpty
                        ? conversation.participantName.substring(0, 1).toUpperCase()
                        : '?'),
                  ),
                  title: Text(conversation.participantName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  subtitle: Text(conversation.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: conversation.unreadCount > 0
                      ? CircleAvatar(radius: 10.r, backgroundColor: const Color(0xFF2E7D3E), child: Text('${conversation.unreadCount}', style: TextStyle(fontSize: 10.sp, color: Colors.white)))
                      : const Icon(Icons.lock_rounded, color: Color(0xFF2E7D3E)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: conversation.id,
                        participantName: conversation.participantName,
                      ),
                    ));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D3E),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}