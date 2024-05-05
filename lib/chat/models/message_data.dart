import 'message.dart';
import 'user.dart';

class AlohaMessageData {
  final User user;

  AlohaMessageData({required this.user});

  MessageData toMessageData() => {'type': 'aloha', ...user.toJson()};
}

class HereIsMessageData {
  final User user;
  final bool isTalking;

  HereIsMessageData({required this.user, required this.isTalking});

  MessageData toMessageData() => {
        'type': 'hereIs',
        ...user.toJson(),
        'isTalking': isTalking,
      };
}

class ByeMessageData {
  MessageData toMessageData() => {'type': 'bye'};
}

extension AlohaExtension on MessageData {
  bool get isAlohaData => this['type'] == 'aloha';
  AlohaMessageData toAlohaData() => isAlohaData
      ? AlohaMessageData(user: User.fromJson(this))
      : throw const FormatException();

  bool get isHereIsData => this['type'] == 'hereIs';
  HereIsMessageData toHereIsData() => isHereIsData
      ? HereIsMessageData(
          user: User.fromJson(this),
          isTalking: this['isTalking'],
        )
      : throw const FormatException();

  bool get isByeData => this['type'] == 'bye';
}
