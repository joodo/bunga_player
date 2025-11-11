import 'package:bunga_player/ui/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class TextEditingShortcutWrapper extends SingleChildStatelessWidget {
  const TextEditingShortcutWrapper({
    super.key,
    required super.child,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return DefaultTextEditingShortcuts(
      child: Shortcuts(
        shortcuts: Map.fromEntries(
          context
              .read<ShortcutMappingNotifier>()
              .value
              .values
              .where((e) => e != null)
              .map(
                (key) => MapEntry(key!, DoNothingAndStopPropagationIntent()),
              ),
        ),
        child: child!,
      ),
    );
  }
}
