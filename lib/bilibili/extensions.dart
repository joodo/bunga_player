import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';

// See https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md

extension Wbi on Map<String, String> {
  String asBiliQueryEncWbi(String? mixinKey) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    RegExp unwantedChars = RegExp(r"[!'()*]");
    final sortedList = [
      ...entries,
      MapEntry('wts', currentTime),
    ].sortedBy((element) => element.key).map(
          (entry) => MapEntry(
            entry.key,
            Uri.encodeComponent(
              entry.value.toString().replaceAll(unwantedChars, ''),
            ),
          ),
        );

    final query =
        sortedList.map((entry) => '${entry.key}=${entry.value}').join('&');
    if (mixinKey == null) return query;

    final wRid = md5.convert(utf8.encode(query + mixinKey)).toString();

    final originQuery = Uri(queryParameters: this).query;
    return '$originQuery&w_rid=$wRid&wts=$currentTime';
  }
}
