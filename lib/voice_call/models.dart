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

extension CallExtension on MessageData {
  bool get isCall => this['type'] == 'call';
  CallMessageData toCall() => isCall
      ? CallMessageData(
          action: CallActionType.values.byName(this['action']),
          answerId: this['answerId'],
        )
      : throw const FormatException();
}
