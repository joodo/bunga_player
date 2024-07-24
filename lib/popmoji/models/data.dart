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
          codePoint.split(seperator).map<int>((e) => int.parse(e, radix: 16)));
  static String svgPath(String emoji) =>
      'assets/emojis/emojis/${codePoint(emoji, seperator: '-')}.svg.vec';
  static String lottiePath(String emoji) =>
      'assets/emojis/emojis/${codePoint(emoji)}.json';

  final List<EmojiCategory> categories;
  final Map<String, List<String>> tags;

  EmojiData({required this.categories, required this.tags});

  factory EmojiData.fromJson(Map<String, dynamic> json) =>
      _$EmojiDataFromJson(json);
  Map<String, dynamic> toJson() => _$EmojiDataToJson(this);
}
