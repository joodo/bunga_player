import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

@JsonSerializable()
class EmojiCategory {
  final String name;
  final List<String> emojis;

  EmojiCategory({required this.name, required this.emojis});

  factory EmojiCategory.fromJson(Map<String, dynamic> json) =>
      _$EmojiCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$EmojiCategoryToJson(this);
}

@JsonSerializable()
class EmojiData {
  static String codePoint(String emoji, {String seperator = '_'}) =>
      emoji.runes.map((rune) => rune.toRadixString(16)).join(seperator);
  static String emojiString(String codePoint, {String seperator = '_'}) =>
      String.fromCharCodes(
        codePoint.split(seperator).map<int>((e) => int.parse(e, radix: 16)),
      );
  static String lottiePath(String emoji) =>
      'assets/emojis/lottie/${codePoint(emoji)}.json';

  // Capture the emoji as a standard GPU texture
  static Future<ui.Image> createImage(String emoji, double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontFamily: 'noto_emoji', fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    // Capture the emoji as a standard GPU texture
    return picture.toImage(
      textPainter.width.toInt(),
      textPainter.height.toInt(),
    );
  }

  static Widget createIcon(String emoji, [double? size]) => FittedBox(
    fit: BoxFit.contain,
    child: Text(
      emoji,
      style: TextStyle(fontFamily: 'noto_emoji', fontSize: size),
    ),
  );

  final List<EmojiCategory> categories;
  final Map<String, List<String>> tags;

  EmojiData({required this.categories, required this.tags});

  factory EmojiData.fromJson(Map<String, dynamic> json) =>
      _$EmojiDataFromJson(json);
  Map<String, dynamic> toJson() => _$EmojiDataToJson(this);
}
