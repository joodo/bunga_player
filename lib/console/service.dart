import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

class ConsoleService {
  final logTextController = TextEditingController();
  final watchingValueNotifiers = <String, ValueNotifier>{};

  ConsoleService() {
    logger.stream.listen((logs) {
      logTextController.text += '${logs.join('\n')}\n';
    });
  }
}

extension Watch on ValueNotifier {
  void watchInConsole(String name) =>
      getIt<ConsoleService>().watchingValueNotifiers[name] = this;
}
