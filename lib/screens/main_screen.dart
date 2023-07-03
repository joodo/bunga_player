import 'package:bunga_player/screens/progress_section/progress_section.dart';
import 'package:bunga_player/screens/room_section.dart';
import 'package:bunga_player/screens/control_section/control_section.dart';
import 'package:bunga_player/screens/player_section/player_section.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late final RestartableTimer _hideUITimer = RestartableTimer(
    const Duration(seconds: 3),
    () => UINotifiers().isUIHidden.value = true,
  );

  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  final _videoSectionKey = GlobalKey<State<PlayerSection>>();
  final _roomSectionKey = GlobalKey<State<RoomSection>>();
  @override
  Widget build(Object context) {
    const roomSectionHeight = 36.0;
    const controlSectionHeight = 64.0;

    final playerSection = PlayerSection(key: _videoSectionKey);
    final controlSection = ControlSection(key: _controlSectionKey);
    final roomSection = RoomSection(key: _roomSectionKey);
    const progressSection = ProgressSection();

    return ValueListenableBuilder(
      valueListenable: UINotifiers().isFullScreen,
      builder: (context, isFullScreen, child) {
        if (isFullScreen) {
          final hideableUI = Stack(
            fit: StackFit.loose,
            children: [
              roomSection,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: controlSectionHeight,
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xC0000000)),
                  child: controlSection,
                ),
              ),
              const Positioned(
                bottom: controlSectionHeight - 8,
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
              ValueListenableBuilder(
                valueListenable: UINotifiers().isUIHidden,
                builder: (context, isUIHidden, child) => MouseRegion(
                  opaque: false,
                  cursor: isUIHidden
                      ? SystemMouseCursors.none
                      : SystemMouseCursors.basic,
                  onEnter: (event) => _hideUITimer.reset(),
                  onExit: (event) => _hideUITimer.cancel(),
                  onHover: (event) {
                    _hideUITimer.reset();
                    UINotifiers().isUIHidden.value = false;
                  },
                ),
              ),
              ValueListenableBuilder(
                valueListenable: UINotifiers().isUIHidden,
                builder: (context, isUIHidden, child) => AnimatedOpacity(
                  opacity: isUIHidden ? 0.0 : 1.0,
                  curve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                ),
                child: hideableUI,
              ),
            ],
          );
        } else {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                height: roomSectionHeight,
                left: 0,
                right: 0,
                child: roomSection,
              ),
              Positioned(
                top: roomSectionHeight,
                bottom: controlSectionHeight,
                left: 0,
                right: 0,
                child: playerSection,
              ),
              Positioned(
                height: controlSectionHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: controlSection,
              ),
              const Positioned(
                bottom: controlSectionHeight - 8,
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
  }
}
