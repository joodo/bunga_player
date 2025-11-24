import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConsoleService {
  final logTextController = TextEditingController();
  final watchingValueListenables = <String, ValueListenable>{};

  ConsoleService() {
    logger.stream.listen((logs) {
      logTextController.text += '${logs.join('\n')}\n';
    });
  }
}

extension Watch on ValueListenable {
  void watchInConsole(String name) =>
      getIt<ConsoleService>().watchingValueListenables[name] = this;
}
