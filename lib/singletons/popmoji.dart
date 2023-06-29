import 'package:bunga_player/singletons/chat.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class Popmoji {
  // Singleton
  static final _instance = Popmoji._internal();
  factory Popmoji() => _instance;

  final playing = ValueNotifier<String?>(null);

  Popmoji._internal() {
    Chat()
        .messageStream
        .where((message) => message?.text?.split(' ')[0] == 'popmoji')
        .listen((message) {
      receive(message!.text!.split(' ')[1]);
    });
  }

  void send(String code) {
    Chat().sendMessage(Message(text: 'popmoji $code'));
  }

  void receive(String code) {
    playing.value ??= code;
  }
}
