import 'package:bunga_player/chat/models/message.dart';

enum CallActionType {
  ask,
  yes,
  no,
  cancel,
}

class CallMessageData {
  final CallActionType action;
  final String? answerId;

  CallMessageData({required this.action, this.answerId});

  MessageData toMessageData() => {
        'type': 'call',
        'action': action.name,
        'answerId': answerId,
      };
}

enum TalkStatusType {
  start,
  end,
}

class TalkStatusMessageData {
  final TalkStatusType status;
  TalkStatusMessageData(this.status);

  MessageData toMessageData() => {
        'type': 'talk',
        'status': status.name,
      };
}

extension CallExtension on MessageData {
  bool get isCallData => this['type'] == 'call';
  CallMessageData toCallData() => isCallData
      ? CallMessageData(
          action: CallActionType.values.byName(this['action']),
          answerId: this['answerId'],
        )
      : throw const FormatException();

  bool get isTalkStatusData => this['type'] == 'talk';
  TalkStatusMessageData toTalkStatusData() => isTalkStatusData
      ? TalkStatusMessageData(TalkStatusType.values.byName(this['status']))
      : throw const FormatException();
}
