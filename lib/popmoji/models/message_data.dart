import 'package:bunga_player/chat/models/message.dart';

class PopmojiMessageData {
  final String code;
  PopmojiMessageData({required this.code});

  MessageData toMessageData() => {'type': 'popmoji', 'code': code};
}

extension PopmojiExtension on MessageData {
  bool get isPopmojiData => this['type'] == 'popmoji';
  PopmojiMessageData toPopmojiData() => isPopmojiData
      ? PopmojiMessageData(code: this['code'])
      : throw const FormatException();
}
