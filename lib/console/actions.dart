import 'dart:async';

import 'package:bunga_player/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';

import 'widget.dart';

class ShowConsoleIntent extends Intent {}

class ShowConsoleAction extends ContextAction<ShowConsoleIntent> {
  final TextEditingController logTextController;

  ShowConsoleAction({required this.logTextController});

  @override
  Future<void> invoke(Intent intent, [BuildContext? context]) async {
    showDialog(
      context: context!,
      builder: (context) => Dialog.fullscreen(
        child: ConsoleDialog(
          logTextController: logTextController,
        ),
      ),
    );
  }
}

class ConsoleActions extends SingleChildStatefulWidget {
  const ConsoleActions({super.key, super.child});

  @override
  State<ConsoleActions> createState() => _ConsoleActionsState();
}

class _ConsoleActionsState extends SingleChildState<ConsoleActions> {
  final _logTextController = TextEditingController();
  late final StreamSubscription _subscribe;

  @override
  void initState() {
    super.initState();
    _subscribe = logger.stream.listen((logs) {
      _logTextController.text += '${logs.join('\n')}\n';
    });
  }

  @override
  void dispose() {
    _subscribe.cancel();
    _logTextController.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.f12): ShowConsoleIntent(),
      },
      child: Actions(
        actions: {
          ShowConsoleIntent:
              ShowConsoleAction(logTextController: _logTextController),
        },
        child: Focus(
          autofocus: true,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
