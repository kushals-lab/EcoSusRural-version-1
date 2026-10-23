import 'dart:convert';

class NativeCompressor {
  static String compress(String input) {
    List<int> bytes = utf8.encode(input);
    return base64Encode(bytes);
  }

  static String decompress(String input) {
    List<int> bytes = base64Decode(input);
    return utf8.decode(bytes);
  }
}