import 'package:bunga_player/chat/models/message.dart';

class PopmojiMessageData {
  final String code;
  PopmojiMessageData({required this.code});

  Map<String, dynamic> toMessageData() => {'type': 'popmoji', 'code': code};
}

extension PopmojiExtension on Map<String, dynamic> {
  bool get isPopmojiData => this['type'] == 'popmoji';
  PopmojiMessageData toPopmojiData() => isPopmojiData
      ? PopmojiMessageData(code: this['code'])
      : throw const FormatException();
}
