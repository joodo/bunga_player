import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

class ConsoleService {
  final logTextController = TextEditingController();
  final watchingListenables = <String, Listenable>{};

  ConsoleService() {
    logger.stream.listen((logs) {
      logTextController.text += '${logs.join('\n')}\n';
    });
  }
}

extension Watch on Listenable {
  void watchInConsole(String name) =>
      getIt<ConsoleService>().watchingListenables[name] = this;
}
