import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

class ConsoleService {
  final watchingListenables = <String, Listenable>{};

  ConsoleService();
}

extension Watch on Listenable {
  void watchInConsole(String name) =>
      getIt<ConsoleService>().watchingListenables[name] = this;
}
