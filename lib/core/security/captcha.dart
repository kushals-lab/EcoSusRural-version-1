import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A self-contained, reusable captcha challenge used across EcoSusRural flows
/// (scheme applications, video uploads, verification screens...).
///
/// Every step that must be protected shows one [CaptchaField]; the flow can
/// only continue when [CaptchaFieldState.validate] returns true. Refreshing
/// regenerates the challenge and clears the input.
class CaptchaChallenge {
  final String code;

  const CaptchaChallenge(this.code);

  /// 5-character code without ambiguous glyphs (no 0/O/1/I).
  static CaptchaChallenge generate([Random? random]) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = random ?? Random();
    final code = String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => alphabet.codeUnitAt(rng.nextInt(alphabet.length)),
      ),
    );
    return CaptchaChallenge(code);
  }
}

/// Displays the captcha code with distortion (rotated glyphs + noise lines) so
/// it cannot be trivially read by scripts, plus a refresh button and the input
/// field. Call [CaptchaFieldState.validate] before moving to the next step.
class CaptchaField extends StatefulWidget {
  /// Controller for the user's answer (owned by the parent screen).
  final TextEditingController controller;

  /// Localized captions; fall back to English when omitted.
  final String? label;
  final String? hint;
  final String? wrongMessage;

  /// Extra note shown next to the challenge (e.g. why it is required here).
  final String? note;

  const CaptchaField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.wrongMessage,
    this.note,
  });

  @override
  State<CaptchaField> createState() => CaptchaFieldState();
}

class CaptchaFieldState extends State<CaptchaField> {
  CaptchaChallenge _challenge = CaptchaChallenge.generate();
  String? _errorText;

  /// Generates a fresh challenge and clears the answer.
  void regenerate() {
    if (!mounted) return;
    setState(() {
      _challenge = CaptchaChallenge.generate();
      _errorText = null;
      widget.controller.clear();
    });
  }

  /// True when the typed answer matches the current challenge
  /// (case-insensitive). On failure an error is shown and a new challenge is
  /// generated, mirroring the platform behaviour.
  bool validate() {
    final answer = widget.controller.text.trim().toUpperCase();
    if (answer.length == _challenge.code.length && answer == _challenge.code) {
      if (_errorText != null && mounted) setState(() => _errorText = null);
      return true;
    }
    if (mounted) {
      setState(() {
        _errorText = widget.wrongMessage ?? 'Incorrect captcha. Try again.';
        _challenge = CaptchaChallenge.generate();
        widget.controller.clear();
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security, size: 16.r, color: const Color(0xFF1B4D3E)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                widget.label ?? 'Captcha Verification',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        if (widget.note != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.note!,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ],
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: regenerate,
              child: _CaptchaCanvas(challenge: _challenge),
            ),
            SizedBox(width: 10.w),
            IconButton(
              tooltip: 'Refresh captcha',
              onPressed: regenerate,
              icon: const Icon(Icons.refresh, color: Color(0xFF1B4D3E)),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.characters,
          maxLength: _challenge.code.length,
          decoration: InputDecoration(
            counterText: '',
            errorText: _errorText,
            hintText: widget.hint ?? 'Enter the characters shown',
            prefixIcon: const Icon(Icons.shield_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF1B4D3E)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the challenge: every glyph is rotated/skewed by a code-seeded random
/// so the same code always renders identically within a challenge, plus noise
/// lines that make automated reading harder.
class _CaptchaCanvas extends StatelessWidget {
  final CaptchaChallenge challenge;

  const _CaptchaCanvas({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3EF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CustomPaint(
        painter: _CaptchaPainter(code: challenge.code),
      ),
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  final String code;

  _CaptchaPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || code.isEmpty) return;

    // Deterministic per-code randomness (stable repaints, no flicker).
    final rng = Random(code.hashCode);

    final noise = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.25 + 0.25 * i);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (rng.nextDouble() - 0.5) * 8),
        noise,
      );
    }

    final slot = size.width / code.length;
    for (var i = 0; i < code.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: code[i],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.blueGrey[800],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      final center = Offset(slot * (i + 0.5), size.height / 2);
      canvas.translate(center.dx, center.dy);
      canvas.rotate((rng.nextDouble() - 0.5) * 0.6);
      canvas.translate(-tp.width / 2, -tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) =>
      oldDelegate.code != code;
}
