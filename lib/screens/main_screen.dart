import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/screens/control_section/control_section.dart';
import 'package:bunga_player/screens/player_section/player_section.dart';
import 'package:bunga_player/screens/player_section/video_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _isUIHiddenNotifier = ValueNotifier<bool>(false);
  final _isBusyNotifier = ValueNotifier<bool>(false);
  final _hintTextNotifier = ValueNotifier<String?>(null);

  late final RestartableTimer _hideUITimer;

  @override
  void initState() {
    super.initState();

    _hideUITimer = RestartableTimer(const Duration(seconds: 3), () {
      _isUIHiddenNotifier.value = true;
    });
  }

  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  final _videoSectionKey = GlobalKey<State<VideoSection>>();
  @override
  Widget build(Object context) {
    const roomSectionHeight = 36.0;
    const controlSectionHeight = 64.0;

    final videoSection = VideoSection(
      key: _videoSectionKey,
      hintTextNotifier: _hintTextNotifier,
    );
    final controlSection = ControlSection(
      key: _controlSectionKey,
      isUIHiddenNotifier: _isUIHiddenNotifier,
      isBusyNotifier: _isBusyNotifier,
      hintTextNotifier: _hintTextNotifier,
    );
    final progressSection = ValueListenableBuilder(
      valueListenable: _isBusyNotifier,
      builder: (context, isBusy, child) => isBusy
          ? const Center(
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(),
              ),
            )
          : const VideoProgressWidget(),
    );

    return ValueListenableBuilder(
      valueListenable: FullScreen().notifier,
      builder: (context, isFullScreen, child) {
        if (isFullScreen) {
          final hideableUI = Stack(
            fit: StackFit.loose,
            children: [
              const RoomSection(),
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
              Positioned(
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
              videoSection,
              ValueListenableBuilder(
                valueListenable: _isUIHiddenNotifier,
                builder: (context, isUIHidden, child) => MouseRegion(
                  opaque: false,
                  cursor: isUIHidden
                      ? SystemMouseCursors.none
                      : SystemMouseCursors.basic,
                  onEnter: (event) => _hideUITimer.reset(),
                  onExit: (event) => _hideUITimer.cancel(),
                  onHover: (event) {
                    _hideUITimer.reset();
                    _isUIHiddenNotifier.value = false;
                  },
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _isUIHiddenNotifier,
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
              const Positioned(
                top: 0,
                height: roomSectionHeight,
                left: 0,
                right: 0,
                child: RoomSection(),
              ),
              Positioned(
                top: roomSectionHeight,
                bottom: controlSectionHeight,
                left: 0,
                right: 0,
                child: videoSection,
              ),
              Positioned(
                height: controlSectionHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: controlSection,
              ),
              Positioned(
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

class RoomSection extends StatelessWidget {
  const RoomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: ListenableBuilder(
        listenable: IMController().channelWatchers,
        builder: (context, child) {
          if (IMController().currentUserNotifier.value == null) {
            return const SizedBox.shrink();
          }

          String text = IMController()
              .channelWatchers
              .toStringExcept(IMController().currentUserNotifier.value!);
          if (text.isEmpty) {
            return const SizedBox.shrink();
          }

          return Text(
            '$text 在和你一起看',
            textAlign: TextAlign.left,
          );
        },
      ),
    );
  }
}
