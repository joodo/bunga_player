// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmojiCategory _$EmojiCategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EmojiCategory', json, ($checkedConvert) {
      final val = EmojiCategory(
        name: $checkedConvert('name', (v) => v as String),
        emojis: $checkedConvert(
          'emojis',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EmojiCategoryToJson(EmojiCategory instance) =>
    <String, dynamic>{'name': instance.name, 'emojis': instance.emojis};

EmojiData _$EmojiDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EmojiData', json, ($checkedConvert) {
      final val = EmojiData(
        categories: $checkedConvert(
          'categories',
          (v) => (v as List<dynamic>)
              .map((e) => EmojiCategory.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        tags: $checkedConvert(
          'tags',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EmojiDataToJson(EmojiData instance) => <String, dynamic>{
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'tags': instance.tags,
};
