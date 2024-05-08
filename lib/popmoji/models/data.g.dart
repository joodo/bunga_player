// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmojiCategory _$EmojiCategoryFromJson(Map<String, dynamic> json) =>
    EmojiCategory(
      name: json['name'] as String,
      emojis:
          (json['emojis'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EmojiCategoryToJson(EmojiCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'emojis': instance.emojis,
    };

EmojiData _$EmojiDataFromJson(Map<String, dynamic> json) => EmojiData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => EmojiCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$EmojiDataToJson(EmojiData instance) => <String, dynamic>{
      'categories': instance.categories,
      'tags': instance.tags,
    };
