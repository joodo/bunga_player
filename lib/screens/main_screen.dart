import 'package:bunga_player/screens/progress_section/progress_section.dart';
import 'package:bunga_player/screens/room_section.dart';
import 'package:bunga_player/screens/control_section/control_section.dart';
import 'package:bunga_player/screens/player_section/player_section.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

const kRoomSectionHeight = 36.0;
const kControlSectionHeight = 64.0;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  final _playerSectionKey = GlobalKey<State<PlayerSection>>();
  final _roomSectionKey = GlobalKey<State<RoomSection>>();
  @override
  Widget build(Object context) {
    final playerSection = PlayerSection(key: _playerSectionKey);
    final controlSection = ControlSection(key: _controlSectionKey);
    final roomSection = RoomSection(key: _roomSectionKey);
    const progressSection = ProgressSection();

    final body = ValueListenableBuilder(
      valueListenable: UINotifiers().isFullScreen,
      builder: (context, isFullScreen, child) {
        if (isFullScreen) {
          final hideableUI = Stack(
            fit: StackFit.loose,
            children: [
              Container(
                color: const Color(0xA0000000),
                child: roomSection,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: kControlSectionHeight,
                child: controlSection,
              ),
              const Positioned(
                bottom: kControlSectionHeight - 8,
                left: 0,
                right: 0,
                height: 16,
                child: progressSection,
              ),
            ],
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              playerSection,
              HideWrapper(child: hideableUI),
            ],
          );
        } else {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                height: kRoomSectionHeight,
                left: 0,
                right: 0,
                child: roomSection,
              ),
              Positioned(
                top: kRoomSectionHeight,
                bottom: kControlSectionHeight,
                left: 0,
                right: 0,
                child: playerSection,
              ),
              Positioned(
                height: kControlSectionHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: controlSection,
              ),
              const Positioned(
                bottom: kControlSectionHeight - 8,
                height: 16,
                left: 0,
                right: 0,
                child: progressSection,
              ),
            ],
          );
        }
      },
    );

    return Material(
      color: Colors.black,
      child: body,
    );
  }
}

class HideWrapper extends StatefulWidget {
  final Widget child;

  const HideWrapper({super.key, required this.child});

  @override
  State<HideWrapper> createState() => _HideWrapperState();
}

class _HideWrapperState extends State<HideWrapper> {
  late final RestartableTimer _hideUITimer = RestartableTimer(
    const Duration(seconds: 3),
    () => UINotifiers().isUIHidden.value = true,
  );

  @override
  void dispose() {
    // for anime
    Future.microtask(() {
      UINotifiers().isUIHidden.value = false;
      _hideUITimer.cancel();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isUIHidden,
      builder: (context, isUIHidden, child) => MouseRegion(
        opaque: false,
        cursor: isUIHidden ? SystemMouseCursors.none : SystemMouseCursors.basic,
        onEnter: (event) => _hideUITimer.reset(),
        onExit: (event) => _hideUITimer.cancel(),
        onHover: (event) {
          _hideUITimer.reset();
          UINotifiers().isUIHidden.value = false;
        },
        child: AnimatedOpacity(
          opacity: isUIHidden ? 0.0 : 1.0,
          curve: Curves.easeInCubic,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
