import 'package:bunga_player/screens/player_screen/player/saved_position_hint.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/progress_bar/progress_section.dart';
import 'package:bunga_player/screens/room_section.dart';
import 'package:bunga_player/screens/control_section/control_section.dart';
import 'package:bunga_player/screens/player_section/player_section.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const roomSectionHeight = 36.0;
  static const controlSectionHeight = 64.0;
  static const progressSectionHeight = 16.0;

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  final _playerSectionKey = GlobalKey<State<PlayerSection>>();
  final _roomSectionKey = GlobalKey<State<RoomSection>>();
  @override
  Widget build(BuildContext context) {
    final playerSection = PlayerSection(key: _playerSectionKey);
    final controlSection = ControlSection(key: _controlSectionKey);
    final roomSection = RoomSection(key: _roomSectionKey);
    const progressSection = ProgressBar();

    final body = Consumer<FoldLayout>(
      builder: (context, foldLayout, child) {
        if (foldLayout.value) {
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
                height: MainScreen.controlSectionHeight,
                child: controlSection,
              ),
              const Positioned(
                bottom: MainScreen.controlSectionHeight -
                    MainScreen.progressSectionHeight / 2,
                left: 0,
                right: 0,
                height: MainScreen.progressSectionHeight,
                child: progressSection,
              ),
            ],
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              playerSection,
              _HUDWrapper(child: hideableUI),
              const Positioned(
                bottom: 72,
                right: 12,
                child: SavedPositionHint(),
              ),
            ],
          );
        } else {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                height: MainScreen.roomSectionHeight,
                left: 0,
                right: 0,
                child: roomSection,
              ),
              Positioned(
                top: MainScreen.roomSectionHeight,
                bottom: MainScreen.controlSectionHeight,
                left: 0,
                right: 0,
                child: playerSection,
              ),
              Positioned(
                height: MainScreen.controlSectionHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: controlSection,
              ),
              const Positioned(
                bottom: MainScreen.controlSectionHeight -
                    MainScreen.progressSectionHeight / 2,
                height: 16,
                left: 0,
                right: 0,
                child: progressSection,
              ),
              const Positioned(
                bottom: 72,
                right: 12,
                child: SavedPositionHint(),
              ),
            ],
          );
        }
      },
    );

    return Container(
      color: Colors.black,
      child: body,
    );
  }
}

class _HUDWrapper extends SingleChildStatelessWidget {
  const _HUDWrapper({super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<ShouldShowHUD>(
      builder: (context, shouldShowHUD, child) {
        final animatedOpacity = AnimatedOpacity(
          opacity: shouldShowHUD.value ? 1.0 : 0.0,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !shouldShowHUD.value,
            child: child,
          ),
        );
        if (!kIsDesktop) return animatedOpacity;

        return MouseRegion(
          opaque: false,
          cursor: shouldShowHUD.value
              ? SystemMouseCursors.basic
              : SystemMouseCursors.none,
          onEnter: (event) => shouldShowHUD.unlock('interactive'),
          onHover: (event) {
            if (_isInUISection(context, event)) {
              shouldShowHUD.lockUp('interactive');
            } else {
              shouldShowHUD.unlock('interactive');
              shouldShowHUD.mark();
            }
          },
          child: animatedOpacity,
        );
      },
      child: child,
    );
  }

  bool _isInUISection(BuildContext context, PointerHoverEvent event) {
    final y = event.localPosition.dy;
    final widgetHeight = (context.findRenderObject()! as RenderBox).size.height;

    // In room section
    if (y < MainScreen.roomSectionHeight) return true;

    // In control or progress section
    if (y > widgetHeight - MainScreen.controlSectionHeight) return true;

    return false;
  }
}
