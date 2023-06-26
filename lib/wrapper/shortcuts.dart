import 'package:bunga_player/actions/play.dart' as play;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutsWrapper extends StatelessWidget {
  final Widget child;

  const ShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp):
            play.SetVolumeIntent(10, isIncrease: true),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            play.SetVolumeIntent(-10, isIncrease: true),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            play.SetPositionIntent(Duration(seconds: -5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            play.SetPositionIntent(Duration(seconds: 5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.space): play.TogglePlayIntent(),
        SingleActivator(LogicalKeyboardKey.escape):
            play.SetFullScreenIntent(false),
      },
      child: Actions(
        actions: {...play.bindings},
        child: child,
      ),
    );
  }
}
