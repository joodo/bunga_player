// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientStatusMessageData _$ClientStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ClientStatusMessageData', json, ($checkedConvert) {
  final val = ClientStatusMessageData(
    $checkedConvert('is_pending', (v) => v as bool),
  );
  return val;
}, fieldKeyMap: const {'isPending': 'is_pending'});

Map<String, dynamic> _$ClientStatusMessageDataToJson(
  ClientStatusMessageData instance,
) => <String, dynamic>{'code': instance.code, 'is_pending': instance.isPending};

ChannelStatusMessageData _$ChannelStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ChannelStatusMessageData',
  json,
  ($checkedConvert) {
    final val = ChannelStatusMessageData(
      watcherIds: $checkedConvert(
        'watcher_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      readyIds: $checkedConvert(
        'ready_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      position: $checkedConvert(
        'position',
        (v) => Duration(microseconds: (v as num).toInt()),
      ),
      playStatus: $checkedConvert(
        'play_status',
        (v) => $enumDecode(_$ChannelPlayStatusEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'watcherIds': 'watcher_ids',
    'readyIds': 'ready_ids',
    'playStatus': 'play_status',
  },
);

Map<String, dynamic> _$ChannelStatusMessageDataToJson(
  ChannelStatusMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'watcher_ids': instance.watcherIds,
  'ready_ids': instance.readyIds,
  'position': instance.position.inMicroseconds,
  'play_status': _$ChannelPlayStatusEnumMap[instance.playStatus]!,
};

const _$ChannelPlayStatusEnumMap = {
  ChannelPlayStatus.paused: 'paused',
  ChannelPlayStatus.pending: 'pending',
  ChannelPlayStatus.playing: 'playing',
};

PlayMessageData _$PlayMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayMessageData', json, ($checkedConvert) {
      final val = PlayMessageData();
      return val;
    });

Map<String, dynamic> _$PlayMessageDataToJson(PlayMessageData instance) =>
    <String, dynamic>{'code': instance.code};

PauseMessageData _$PauseMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PauseMessageData', json, ($checkedConvert) {
      final val = PauseMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PauseMessageDataToJson(PauseMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

SeekMessageData _$SeekMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SeekMessageData', json, ($checkedConvert) {
      final val = SeekMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SeekMessageDataToJson(SeekMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

PlayFinishedMessageData _$PlayFinishedMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlayFinishedMessageData', json, ($checkedConvert) {
  final val = PlayFinishedMessageData();
  return val;
});

Map<String, dynamic> _$PlayFinishedMessageDataToJson(
  PlayFinishedMessageData instance,
) => <String, dynamic>{'code': instance.code};

ShareSubMessageData _$ShareSubMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShareSubMessageData', json, ($checkedConvert) {
      final val = ShareSubMessageData(
        url: $checkedConvert('url', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ShareSubMessageDataToJson(
  ShareSubMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'title': instance.title,
};
