import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../crypto/e2ee_service.dart';

/// WhatsApp-style "Security code" screen — out-of-band verification of the
/// end-to-end encryption identity for a conversation.
class SecurityCodeScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;

  const SecurityCodeScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
  });

  @override
  ConsumerState<SecurityCodeScreen> createState() => _SecurityCodeScreenState();
}

class _SecurityCodeScreenState extends ConsumerState<SecurityCodeScreen> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final code = await E2eeService.securityCode(widget.conversationId);
      setState(() => _code = code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Encryption',
          style: TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCF2C0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: Color(0xFF2E7D3E), size: 44),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Messages with ${widget.participantName} are protected with end-to-end encryption.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'This code can be used to verify that your calls and messages are encrypted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8EE),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF2E7D3E)),
              ),
              child: Center(
                child: Text(
                  _code.isEmpty ? '…' : _code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF1B4D3E),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5.sp,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Code re-syncs when ${widget.participantName} joins a new device',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}