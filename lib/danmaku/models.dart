import 'package:bunga_player/chat/models/message.dart';

class DanmakuMessageData {
  final String text;
  DanmakuMessageData({required this.text});

  MessageData toMessageData() => {'type': 'danmaku', 'text': text};
}

extension DanmakuExtension on MessageData {
  bool get isDanmakuData => this['type'] == 'danmaku';
  DanmakuMessageData toDanmakuData() => isDanmakuData
      ? DanmakuMessageData(text: this['text'])
      : throw const FormatException();
}
