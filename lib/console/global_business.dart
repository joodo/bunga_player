import 'package:bunga_player/screens/widgets/split_view.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

import 'service.dart';
import 'widget.dart';

class ToggleConsoleIntent extends Intent {}

class ConsoleGlobalBusiness extends SingleChildStatefulWidget {
  const ConsoleGlobalBusiness({super.key, super.child});

  @override
  State<ConsoleGlobalBusiness> createState() => ConsoleGlobalBusinessState();
}

class ConsoleGlobalBusinessState
    extends SingleChildState<ConsoleGlobalBusiness> {
  bool _showConsole = false;
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final focus = Focus(
      autofocus: true,
      child: child ?? const SizedBox.shrink(),
    );

    final console = Console(
      logTextController: getIt<ConsoleService>().logTextController,
    ).splitView(
      minSize: 300.0,
      size: 400.0,
      maxSize: 1000.0,
      direction: AxisDirection.right,
    );

    final row = [
      if (_showConsole) console,
      focus.expanded(),
    ].toRow();

    final actions = Actions(
      actions: {
        ToggleConsoleIntent: CallbackAction<ToggleConsoleIntent>(
          onInvoke: (intent) {
            setState(() {
              _showConsole = !_showConsole;
            });
            return null;
          },
        ),
      },
      child: row,
    );

    final shortcuts = Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.f12): ToggleConsoleIntent(),
      },
      child: actions,
    );

    return MaterialApp(
      home: Material(child: shortcuts),
    );
  }
}
