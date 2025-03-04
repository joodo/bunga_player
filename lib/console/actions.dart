import 'dart:async';

import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';

import 'service.dart';
import 'widget.dart';

class ShowConsoleIntent extends Intent {}

class ShowConsoleAction extends ContextAction<ShowConsoleIntent> {
  ShowConsoleAction();

  @override
  Future<void> invoke(Intent intent, [BuildContext? context]) async {
    showDialog(
      context: context!,
      builder: (context) => Dialog.fullscreen(
        child: ConsoleDialog(
          logTextController: getIt<ConsoleService>().logTextController,
        ),
      ),
    );
  }
}

class ConsoleActions extends SingleChildStatelessWidget {
  const ConsoleActions({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.f12): ShowConsoleIntent(),
      },
      child: Actions(
        actions: {
          ShowConsoleIntent: ShowConsoleAction(),
        },
        child: Focus(
          autofocus: true,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
