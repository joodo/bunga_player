import 'dart:math';

import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/control_section.dart';
import 'package:bunga_player/screens/player_widget/popmoji_player.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final _isUIHidden = ValueNotifier<bool>(false);
  late final RestartableTimer _hideUITimer;

  @override
  void initState() {
    super.initState();

    _hideUITimer = RestartableTimer(const Duration(seconds: 3), () {
      _isUIHidden.value = true;
    });

    // FIXME: open must execute after Video widget loaded
    Future.delayed(Duration.zero, VideoController().openVideo);
  }

  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  @override
  Widget build(Object context) {
    const roomSectionHeight = 36.0;
    const controlSectionHeight = 64.0;

    const videoSection = VideoSection();
    final controlSection = ControlSection(
      key: _controlSectionKey,
      isUIHidden: _isUIHidden,
    );
    const progressSection = VideoProgressWidget();

    final body = ValueListenableBuilder(
      valueListenable: FullScreen().notifier,
      builder: (context, isFullScreen, child) {
        if (isFullScreen) {
          return Stack(
            fit: StackFit.expand,
            children: [
              videoSection,
              ValueListenableBuilder(
                valueListenable: _isUIHidden,
                builder: (context, isUIHidden, child) => MouseRegion(
                  opaque: false,
                  cursor: isUIHidden
                      ? SystemMouseCursors.none
                      : SystemMouseCursors.basic,
                  onEnter: (event) => _hideUITimer.reset(),
                  onExit: (event) => _hideUITimer.cancel(),
                  onHover: (event) {
                    _hideUITimer.reset();
                    _isUIHidden.value = false;
                  },
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _isUIHidden,
                builder: (context, isUIHidden, child) => AnimatedOpacity(
                  opacity: isUIHidden ? 0.0 : 1.0,
                  curve: Curves.easeInCubic,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                ),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    const RoomSection(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: controlSectionHeight,
                      child: Container(
                        decoration:
                            const BoxDecoration(color: Color(0xC0000000)),
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
                ),
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
              const Positioned(
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

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          final targetVolume = min(VideoController().volume.value + 10, 100.0);
          VideoController().volume.value = targetVolume;
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          final targetVolume = max(VideoController().volume.value - 10, 0.0);
          VideoController().volume.value = targetVolume;
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          final targetPosition =
              max(VideoController().position.value.inMilliseconds - 5000, 0);
          VideoController().jumpTo(Duration(milliseconds: targetPosition));
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          final targetPosition = min(
              VideoController().position.value.inMilliseconds + 5000,
              VideoController().duration.value.inMilliseconds);
          VideoController().jumpTo(Duration(milliseconds: targetPosition));
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          VideoController().togglePlay();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          FullScreen().set(false);
        },
      },
      child: Focus(
        autofocus: true,
        child: body,
      ),
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
          String text = IMController()
              .channelWatchers
              .toStringExcept(IMController().currentUser!);
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

class VideoSection extends StatelessWidget {
  const VideoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: FullScreen().toggle,
      onTap: VideoController().togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          media_kit_video.Video(
            controller: VideoController().controller,
          ),
          const PopmojiPlayer(),
        ],
      ),
    );
  }
}
