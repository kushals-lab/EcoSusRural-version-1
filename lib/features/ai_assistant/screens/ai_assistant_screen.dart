import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/chat_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final primaryGreen = const Color(0xFF1B4D3E);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: primaryGreen),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'EcoSusRural AI',
                style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: primaryGreen.withValues(alpha: 0.25)),
              ),
              child: Text(
                'EcoSusRural Rural Intelligence',
                style: TextStyle(fontSize: 9.sp, color: primaryGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Mandatory persistent AI safety disclaimer (Blueprint 2.2).
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 18.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'WARNING: AI can make mistakes. Verify critical agronomic, legal, or financial information with certified human experts.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.r),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          
          // Input Area
          _buildInputArea(ref),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: msg.isUser ? Radius.circular(16.r) : const Radius.circular(0),
            bottomRight: msg.isUser ? const Radius.circular(0) : Radius.circular(16.r),
          ),
          border: msg.isUser ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.hasImage) ...[
              Icon(Icons.image, color: Colors.white, size: 40.r), // Placeholder for actual image
              SizedBox(height: 8.h),
            ],
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt, color: primaryGreen),
              onPressed: () {
                // Simulate sending a pest image
                ref.read(chatProvider.notifier).sendMessage('What is wrong with my crop?', hasImage: true);
                _scrollToBottom();
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type or speak...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                if (_controller.text.isNotEmpty) {
                  ref.read(chatProvider.notifier).sendMessage(_controller.text);
                  _controller.clear();
                  _scrollToBottom();
                }
              },
              child: CircleAvatar(
                backgroundColor: primaryGreen,
                radius: 22.r,
                child: Icon(Icons.send, color: Colors.white, size: 20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}