import 'dart:convert';
import 'dart:io';

extension Compression on String {
  String compress() {
    return base64.encode(gzip.encode(utf8.encode(this)));
  }

  String decompress() {
    return utf8.decode(gzip.decode(base64.decode(this)));
  }
}
