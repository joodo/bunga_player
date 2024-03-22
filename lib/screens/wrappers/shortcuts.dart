import 'package:bunga_player/actions/play.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

class ShortcutsWrapper extends SingleChildStatelessWidget {
  const ShortcutsWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp):
            SetVolumeIntent.increase(10),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            SetVolumeIntent.increase(-10),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            SeekIntent(Duration(seconds: -5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            SeekIntent(Duration(seconds: 5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.space): TogglePlayIntent(),
      },
      child: child!,
    );
  }
}
