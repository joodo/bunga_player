import 'package:bunga_player/common/im_controller.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class PopmojiController {
  // Singleton
  static final _instance = PopmojiController._internal();
  factory PopmojiController() => _instance;

  final playing = ValueNotifier<String?>(null);

  PopmojiController._internal();

  void send(String code) {
    IMController().sendMessage(Message(text: 'popmoji $code'));
  }

  void receive(String code) {
    playing.value ??= code;
  }
}
