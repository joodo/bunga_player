import 'package:bunga_player/screens/widgets/split_view.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'widget.dart';

class ToggleConsoleIntent extends Intent {}

class ConsolePositionNotifier extends ValueNotifier<AxisDirection> {
  ConsolePositionNotifier() : super(.left) {
    bindPreference<String>(
      key: 'console_position',
      load: (pref) => enumFromString(AxisDirection.values, pref) ?? .left,
      update: (value) => value.name,
    );
  }
}

class ConsoleWrapper extends SingleChildStatefulWidget {
  const ConsoleWrapper({super.key, super.child});

  @override
  State<ConsoleWrapper> createState() => ConsoleWrapperState();
}

class ConsoleWrapperState extends SingleChildState<ConsoleWrapper> {
  bool _showConsole = false;

  final _consolePositionNotifier = ConsolePositionNotifier();

  @override
  void dispose() {
    _consolePositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final focus = Focus(
      autofocus: true,
      child: child ?? const SizedBox.shrink(),
    );

    final split = ValueListenableBuilder(
      valueListenable: _consolePositionNotifier,
      builder: (context, direction, child) => focus.splitView(
        minSize: 300.0,
        size: 400.0,
        maxSize: 1000.0,
        direction: direction,
        split: _showConsole ? const Console() : null,
      ),
    );

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
      child: split,
    );

    final shortcuts = Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.f12): ToggleConsoleIntent(),
      },
      child: actions,
    );

    final provider = Provider.value(
      value: _consolePositionNotifier,
      child: shortcuts,
    );

    return provider;
  }
}
