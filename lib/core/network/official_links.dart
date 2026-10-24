import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isSecureOfficialUrl(String? raw) {
  final uri = Uri.tryParse(raw ?? '');
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty && uri.userInfo.isEmpty;
}
Future<bool> openOfficialLink(BuildContext context, String? url) async {
  try {
    if (!isSecureOfficialUrl(url)) throw const FormatException('Missing official HTTPS link');
    final opened = await launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
    if (!opened) throw StateError('Browser unavailable');
    return true;
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open this official link. Please try again.')));
    return false;
  }
}
