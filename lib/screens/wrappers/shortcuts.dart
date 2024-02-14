import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/actions/bindings.dart';
import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/play.dart' as play;
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Intentor extends StatefulWidget {
  static final _globalKey = GlobalKey<State<Intentor>>();
  static BuildContext get context => _globalKey.currentContext!;

  final Widget child;

  const Intentor({super.key, required this.child});

  @override
  State<Intentor> createState() => _IntentorState();
}

class _IntentorState extends State<Intentor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

class ShortcutsWrapper extends StatelessWidget {
  final Widget child;

  const ShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Widget child = this.child;
    child = Intentor(
      key: Intentor._globalKey,
      child: child,
    );
    child = VoiceCallActions(child: child);
    child = ChannelActions(child: child);
    child = VideoPlayingActions(child: child);
    child = AuthActions(child: child);

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
        dispatcher: LoggingActionDispatcher(),
        actions: actionBindings,
        child: child,
      ),
    );
  }
}
