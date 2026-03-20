// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhatsOnMessageData _$WhatsOnMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WhatsOnMessageData', json, ($checkedConvert) {
      final val = WhatsOnMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$WhatsOnMessageDataToJson(WhatsOnMessageData instance) =>
    <String, dynamic>{'code': instance.$type};

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
    $type: $checkedConvert('code', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$NowPlayingMessageDataToJson(
  NowPlayingMessageData instance,
) => <String, dynamic>{
  'record': instance.record.toJson(),
  'sharer': instance.sharer.toJson(),
  'code': instance.$type,
};

JoinInMessageData _$JoinInMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'JoinInMessageData',
      json,
      ($checkedConvert) {
        final val = JoinInMessageData(
          user: $checkedConvert(
            'user',
            (v) => User.fromJson(v as Map<String, dynamic>),
          ),
          myShare: $checkedConvert(
            'my_share',
            (v) => v == null
                ? null
                : StartProjectionMessageData.fromJson(
                    v as Map<String, dynamic>,
                  ),
          ),
          $type: $checkedConvert('code', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'myShare': 'my_share', r'$type': 'code'},
    );

Map<String, dynamic> _$JoinInMessageDataToJson(JoinInMessageData instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'my_share': instance.myShare?.toJson(),
      'code': instance.$type,
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
        talking: $checkedConvert(
          'talking',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$HereAreMessageDataToJson(HereAreMessageData instance) =>
    <String, dynamic>{
      'watchers': instance.watchers.map((e) => e.toJson()).toList(),
      'buffering': instance.buffering,
      'talking': instance.talking,
      'code': instance.$type,
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
      $type: $checkedConvert('code', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'videoRecord': 'video_record', r'$type': 'code'},
);

Map<String, dynamic> _$StartProjectionMessageDataToJson(
  StartProjectionMessageData instance,
) => <String, dynamic>{
  'video_record': instance.videoRecord.toJson(),
  'position': instance.position.inMicroseconds,
  'code': instance.$type,
};

ResetMessageData _$ResetMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ResetMessageData', json, ($checkedConvert) {
      final val = ResetMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$ResetMessageDataToJson(ResetMessageData instance) =>
    <String, dynamic>{'code': instance.$type};

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AlohaMessageData', json, ($checkedConvert) {
      final val = AlohaMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{'code': instance.$type};

ByeMessageData _$ByeMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ByeMessageData', json, ($checkedConvert) {
      final val = ByeMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{'code': instance.$type};

WhoAreYouMessageData _$WhoAreYouMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WhoAreYouMessageData', json, ($checkedConvert) {
  final val = WhoAreYouMessageData(
    $type: $checkedConvert('code', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$WhoAreYouMessageDataToJson(
  WhoAreYouMessageData instance,
) => <String, dynamic>{'code': instance.$type};

ClientStatusMessageData _$ClientStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ClientStatusMessageData',
  json,
  ($checkedConvert) {
    final val = ClientStatusMessageData(
      isPending: $checkedConvert('is_pending', (v) => v as bool),
      $type: $checkedConvert('code', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'isPending': 'is_pending', r'$type': 'code'},
);

Map<String, dynamic> _$ClientStatusMessageDataToJson(
  ClientStatusMessageData instance,
) => <String, dynamic>{
  'is_pending': instance.isPending,
  'code': instance.$type,
};

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
      $type: $checkedConvert('code', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'watcherIds': 'watcher_ids',
    'readyIds': 'ready_ids',
    'playStatus': 'play_status',
    r'$type': 'code',
  },
);

Map<String, dynamic> _$ChannelStatusMessageDataToJson(
  ChannelStatusMessageData instance,
) => <String, dynamic>{
  'watcher_ids': instance.watcherIds,
  'ready_ids': instance.readyIds,
  'position': instance.position.inMicroseconds,
  'play_status': _$ChannelPlayStatusEnumMap[instance.playStatus]!,
  'code': instance.$type,
};

const _$ChannelPlayStatusEnumMap = {
  ChannelPlayStatus.paused: 'paused',
  ChannelPlayStatus.pending: 'pending',
  ChannelPlayStatus.playing: 'playing',
};

PlayMessageData _$PlayMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayMessageData', json, ($checkedConvert) {
      final val = PlayMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$PlayMessageDataToJson(PlayMessageData instance) =>
    <String, dynamic>{'code': instance.$type};

PauseMessageData _$PauseMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PauseMessageData', json, ($checkedConvert) {
      final val = PauseMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$PauseMessageDataToJson(PauseMessageData instance) =>
    <String, dynamic>{
      'position': instance.position.inMicroseconds,
      'code': instance.$type,
    };

SeekMessageData _$SeekMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SeekMessageData', json, ($checkedConvert) {
      final val = SeekMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$SeekMessageDataToJson(SeekMessageData instance) =>
    <String, dynamic>{
      'position': instance.position.inMicroseconds,
      'code': instance.$type,
    };

PlayFinishedMessageData _$PlayFinishedMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlayFinishedMessageData', json, ($checkedConvert) {
  final val = PlayFinishedMessageData(
    $type: $checkedConvert('code', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$PlayFinishedMessageDataToJson(
  PlayFinishedMessageData instance,
) => <String, dynamic>{'code': instance.$type};

ShareSubMessageData _$ShareSubMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShareSubMessageData', json, ($checkedConvert) {
      final val = ShareSubMessageData(
        url: $checkedConvert('url', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$ShareSubMessageDataToJson(
  ShareSubMessageData instance,
) => <String, dynamic>{
  'url': instance.url,
  'title': instance.title,
  'code': instance.$type,
};

CallMessageData _$CallMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CallMessageData', json, ($checkedConvert) {
      final val = CallMessageData(
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$CallActionEnumMap, v),
        ),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$CallMessageDataToJson(CallMessageData instance) =>
    <String, dynamic>{
      'action': _$CallActionEnumMap[instance.action]!,
      'code': instance.$type,
    };

const _$CallActionEnumMap = {
  CallAction.call: 'call',
  CallAction.accept: 'accept',
  CallAction.reject: 'reject',
  CallAction.cancel: 'cancel',
};

TalkStatusMessageData _$TalkStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TalkStatusMessageData', json, ($checkedConvert) {
  final val = TalkStatusMessageData(
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$TalkStatusEnumMap, v),
    ),
    $type: $checkedConvert('code', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$TalkStatusMessageDataToJson(
  TalkStatusMessageData instance,
) => <String, dynamic>{
  'status': _$TalkStatusEnumMap[instance.status]!,
  'code': instance.$type,
};

const _$TalkStatusEnumMap = {TalkStatus.start: 'start', TalkStatus.end: 'end'};

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PopmojiMessageData',
      json,
      ($checkedConvert) {
        final val = PopmojiMessageData(
          popmojiCode: $checkedConvert('popmoji_code', (v) => v as String),
          $type: $checkedConvert('code', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'popmojiCode': 'popmoji_code', r'$type': 'code'},
    );

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'popmoji_code': instance.popmojiCode,
      'code': instance.$type,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DanmakuMessageData', json, ($checkedConvert) {
      final val = DanmakuMessageData(
        message: $checkedConvert('message', (v) => v as String),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{'message': instance.message, 'code': instance.$type};

SparkMessageData _$SparkMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SparkMessageData', json, ($checkedConvert) {
      final val = SparkMessageData(
        emoji: $checkedConvert('emoji', (v) => v as String),
        fraction: $checkedConvert(
          'fraction',
          (v) => _fractionalOffsetFromJson(v as List),
        ),
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$SparkMessageDataToJson(SparkMessageData instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'fraction': _fractionalOffsetToJson(instance.fraction),
      'code': instance.$type,
    };

UnknownMessageData _$UnknownMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UnknownMessageData', json, ($checkedConvert) {
      final val = UnknownMessageData(
        $type: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'code'});

Map<String, dynamic> _$UnknownMessageDataToJson(UnknownMessageData instance) =>
    <String, dynamic>{'code': instance.$type};
