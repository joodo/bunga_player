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

extension Hash on String {
  String get hashStr => hashCode.toRadixString(36);
}

extension ExtractUrls on String {
  List<String> extractUrls() {
    RegExp urlRegExp = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    Iterable<Match> matches = urlRegExp.allMatches(this);

    List<String> urls = [];
    for (Match match in matches) {
      urls.add(match.group(0)!);
    }

    return urls;
  }
}
