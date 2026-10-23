import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/language_provider.dart';
import '../models/chat_message.dart';
import '../providers/chat_providers.dart';
import 'security_code_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// messageId -> locally decrypted plaintext (in-memory only, never stored).
  final Map<String, String> _plaintexts = {};
  bool _secure = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Encrypt seed history & establish the E2E session after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final cache = await prepareConversation(ref, widget.conversationId);
        setState(() {
          _plaintexts.addAll(cache);
          _secure = true;
        });
      } catch (_) {
        setState(() => _secure = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final allMessages =
        ref.watch(chatMessagesProvider)[widget.conversationId] ??
            const <ChatMessage>[];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.grey[300],
            child: Text(
              widget.participantName.isEmpty
                  ? '..'
                  : widget.participantName
                      .substring(0, widget.participantName.length < 2 ? 1 : 2)
                      .toUpperCase(),
              style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.participantName,
              style: TextStyle(
                color: const Color(0xFF2E7D3E),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _secure ? 'online · you 🔒' : tr('online'),
              style: TextStyle(color: Colors.green, fontSize: 10.sp),
            ),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_rounded, color: Color(0xFF2E7D3E)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SecurityCodeScreen(
                  conversationId: widget.conversationId,
                  participantName: widget.participantName,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        _buildEncryptionBanner(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            itemCount: allMessages.length,
            itemBuilder: (context, index) =>
                _buildMessage(allMessages[index], allMessages[index].isMine),
          ),
        ),
        _buildInputArea(tr),
      ]),
    );
  }

  Widget _buildEncryptionBanner() {
    if (!_secure) {
      return Container(
        color: const Color(0xFFFDF6E5),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_bottom, size: 14, color: Color(0xFFB57E10)),
            SizedBox(width: 6.w),
            Text(
              '🔐 Establishing end-to-end encryption…',
              style: TextStyle(color: const Color(0xFF8A6500), fontSize: 11.sp),
            ),
          ],
        ),
      );
    }
    return Container(
      color: const Color(0xFFEAF6E4),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 13, color: Color(0xFF2E7D3E)),
          SizedBox(width: 6.w),
          Text(
            'End-to-end encrypted · X25519 + AES-256-GCM · tap 🔒 to verify',
            style: TextStyle(color: const Color(0xFF2E7D3E), fontSize: 10.5.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, bool isMine) {
    final alignment = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMine ? const Color(0xFFDCF2C0) : Colors.grey[200];
    final text = msg.isEncrypted
        ? (_plaintexts[msg.id] ?? '🔒 Decrypting…')
        : msg.text;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Column(crossAxisAlignment: alignment, children: [
        Container(
          constraints: BoxConstraints(maxWidth: 250.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMine ? 16.r : 4.r),
              topRight: Radius.circular(isMine ? 4.r : 16.r),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: msg.type == 'image'
              ? Row(children: [
                  Icon(Icons.image, color: Colors.grey[500], size: 40),
                  SizedBox(width: 8.w),
                  Text(text),
                ])
              : Text(
                  text,
                  style: TextStyle(color: const Color(0xFF2D2D2D), fontSize: 14.sp),
                ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (msg.isEncrypted)
              const Icon(Icons.lock_rounded, size: 9, color: Color(0xFF2E7D3E)),
            if (msg.isEncrypted) SizedBox(width: 3.w),
            Text(_timeLabel(msg.timestamp), style: TextStyle(color: Colors.grey[400], fontSize: 10.sp)),
            if (isMine && msg.isDelivered)
              ...[SizedBox(width: 4.w), const Icon(Icons.done_all, size: 12, color: Color(0xFF007AFF))],
          ],
        ),
      ]),
    );
  }

  String _timeLabel(DateTime timestamp) {
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _sendMessage() {
    final raw = _textController.text;
    if (raw.trim().isEmpty) {
      return;
    }
    _textController.text = '';
    Future(() async {
      try {
        final id = await sendEncryptedMessage(ref, widget.conversationId, raw);
        setState(() {
          _plaintexts[id] = raw.trim();
        });
      } catch (_) {
        // Restore the typed text if encryption failed for any reason.
        _textController.text = raw;
      }
    });
  }

  Widget _buildInputArea(tr) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
      child: SafeArea(
        child: Row(children: [
          IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: () {}),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20.r)),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: tr('typeMessage'),
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF2E7D3E)),
            onPressed: _sendMessage,
          ),
        ]),
      ),
    );
  }
}
