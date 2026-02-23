// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoAreYouMessageData _$WhoAreYouMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WhoAreYouMessageData', json, ($checkedConvert) {
  final val = WhoAreYouMessageData();
  return val;
});

Map<String, dynamic> _$WhoAreYouMessageDataToJson(
  WhoAreYouMessageData instance,
) => <String, dynamic>{'code': instance.code};

WhatsOnMessageData _$WhatsOnMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WhatsOnMessageData', json, ($checkedConvert) {
      final val = WhatsOnMessageData();
      return val;
    });

Map<String, dynamic> _$WhatsOnMessageDataToJson(WhatsOnMessageData instance) =>
    <String, dynamic>{'code': instance.code};

NowPlayingMessageData _$NowPlayingMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NowPlayingMessageData', json, ($checkedConvert) {
  final val = NowPlayingMessageData(
    record: $checkedConvert(
      'record',
      (v) => VideoRecord.fromJson(v as Map<String, dynamic>),
    ),
    sharer: $checkedConvert(
      'sharer',
      (v) => User.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$NowPlayingMessageDataToJson(
  NowPlayingMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'record': instance.record.toJson(),
  'sharer': instance.sharer.toJson(),
};

JoinInMessageData _$JoinInMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JoinInMessageData', json, ($checkedConvert) {
      final val = JoinInMessageData(
        user: $checkedConvert(
          'user',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
        myShare: $checkedConvert(
          'my_share',
          (v) => v == null
              ? null
              : StartProjectionMessageData.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'myShare': 'my_share'});

Map<String, dynamic> _$JoinInMessageDataToJson(JoinInMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'user': instance.user.toJson(),
      'my_share': instance.myShare?.toJson(),
    };

HereAreMessageData _$HereAreMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HereAreMessageData', json, ($checkedConvert) {
      final val = HereAreMessageData(
        watchers: $checkedConvert(
          'watchers',
          (v) => (v as List<dynamic>)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        buffering: $checkedConvert(
          'buffering',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HereAreMessageDataToJson(HereAreMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'watchers': instance.watchers.map((e) => e.toJson()).toList(),
      'buffering': instance.buffering,
    };

StartProjectionMessageData _$StartProjectionMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StartProjectionMessageData',
  json,
  ($checkedConvert) {
    final val = StartProjectionMessageData(
      videoRecord: $checkedConvert(
        'video_record',
        (v) => VideoRecord.fromJson(v as Map<String, dynamic>),
      ),
      position: $checkedConvert(
        'position',
        (v) => v == null
            ? Duration.zero
            : Duration(microseconds: (v as num).toInt()),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'videoRecord': 'video_record'},
);

Map<String, dynamic> _$StartProjectionMessageDataToJson(
  StartProjectionMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'video_record': instance.videoRecord.toJson(),
  'position': instance.position.inMicroseconds,
};

ResetMessageData _$ResetMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ResetMessageData', json, ($checkedConvert) {
      final val = ResetMessageData();
      return val;
    });

Map<String, dynamic> _$ResetMessageDataToJson(ResetMessageData instance) =>
    <String, dynamic>{'code': instance.code};

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AlohaMessageData', json, ($checkedConvert) {
      final val = AlohaMessageData();
      return val;
    });

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{'code': instance.code};

ByeMessageData _$ByeMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ByeMessageData', json, ($checkedConvert) {
      final val = ByeMessageData();
      return val;
    });

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{'code': instance.code};
