// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartProjectionMessageData _$StartProjectionMessageDataFromJson(
        Map<String, dynamic> json) =>
    StartProjectionMessageData(
      sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
      videoRecord:
          VideoRecord.fromJson(json['video_record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StartProjectionMessageDataToJson(
        StartProjectionMessageData instance) =>
    <String, dynamic>{
      'sharer': instance.sharer,
      'video_record': instance.videoRecord,
    };
