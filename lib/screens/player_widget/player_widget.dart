import 'dart:async';
import 'dart:math';

import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/control_section.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart' as meedu;
import 'package:window_manager/window_manager.dart';
import 'package:async/async.dart';

class PlayerWidget extends StatefulWidget {
  final String videoPath;
  final String groupID;

  const PlayerWidget({
    super.key,
    required this.videoPath,
    required this.groupID,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> with WindowListener {
  bool _isFullScreen = false;

  bool _isUIHidden = false;
  late final RestartableTimer _hideUITimer;

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);

    _hideUITimer = RestartableTimer(const Duration(seconds: 3), () {
      setState(() {
        _isUIHidden = true;
      });
    });

    IMController().askPosition();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
  }

  final _controlSectionKey = GlobalKey<State<ControlSection>>();
  @override
  Widget build(Object context) {
    const roomSectionHeight = 36.0;
    const controlSectionHeight = 64.0;

    final videoSection = VideoSection(
      onTap: _togglePlaying,
      onDoubleTap: _toggleFullscreen,
    );
    final controlSection = ControlSection(
      key: _controlSectionKey,
    );
    final progressSection = ProgressSection(
      onChangeEnd: _seekingFinished,
    );

    final Widget body;
    if (_isFullScreen) {
      body = Stack(
        fit: StackFit.expand,
        children: [
          MouseRegion(
            opaque: false,
            cursor: _isUIHidden
                ? SystemMouseCursors.none
                : SystemMouseCursors.basic,
            onEnter: (event) => _hideUITimer.reset(),
            onExit: (event) => _hideUITimer.cancel(),
            onHover: (event) {
              _hideUITimer.reset();
              setState(() {
                _isUIHidden = false;
              });
            },
            child: videoSection,
          ),
          AnimatedOpacity(
            opacity: _isUIHidden ? 0.0 : 1.0,
            curve: Curves.easeInCubic,
            duration: const Duration(milliseconds: 200),
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
            ),
          ),
        ],
      );
    } else {
      body = Stack(
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

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          final controller = VideoController.instance();
          final targetVolume = min(controller.volume.value + 0.1, 1.0);
          _setVolume(targetVolume);
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          final controller = VideoController.instance();
          final targetVolume = max(controller.volume.value - 0.1, 0.0);
          _setVolume(targetVolume);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          final controller = VideoController.instance();
          final targetPosition =
              max(controller.position.value.inMilliseconds - 5000, 0);
          _seekingFinished(Duration(milliseconds: targetPosition));
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          final controller = VideoController.instance();
          final targetPosition = min(
              controller.position.value.inMilliseconds + 5000,
              controller.duration.value.inMilliseconds);
          _seekingFinished(Duration(milliseconds: targetPosition));
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          _togglePlaying();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          windowManager.setFullScreen(false);
        },
      },
      child: Focus(
        autofocus: true,
        child: body,
      ),
    );
  }

  void _toggleFullscreen() {
    windowManager.setFullScreen(!_isFullScreen);
  }

  void _togglePlaying() {
    final controller = VideoController.instance();
    controller.togglePlay().then((_) {
      Future.delayed(Duration.zero, () {
        IMController().sendStatus();
      });
    });
  }

  void _setVolume(double volume) {
    final controller = VideoController.instance();
    controller.setMute(false);
    controller.setVolume(volume);
  }

  void _seekingFinished(Duration position) {
    final controller = VideoController.instance();
    controller.seekTo(position).then((_) {
      IMController().sendStatus();
    });
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

class VideoSection extends StatefulWidget {
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  const VideoSection({
    super.key,
    this.onDoubleTap,
    this.onTap,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      onTap: widget.onTap,
      child: meedu.MeeduVideoPlayer(controller: VideoController.instance()),
    );
  }
}

class ProgressSection extends StatefulWidget {
  final ValueSetter<Duration>? onChangeEnd;

  const ProgressSection({
    super.key,
    this.onChangeEnd,
  });

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  Duration? _changingPosition;

  @override
  Widget build(BuildContext context) {
    final controller = VideoController.instance();
    return StreamBuilder(
      stream: controller.sliderPosition.stream,
      builder: (context, snapshot) {
        return VideoProgressWidget(
          position: _changingPosition ??
              snapshot.data ??
              controller.sliderPosition.value,
          duration: controller.duration.value,
          onChangeStart: (value) {
            setState(() {
              _changingPosition = value;
            });
          },
          onChanged: (value) {
            setState(() {
              _changingPosition = value;
            });
          },
          onChangeEnd: (value) {
            widget.onChangeEnd?.call(_changingPosition!);
            setState(() {
              _changingPosition = null;
            });
          },
        );
      },
    );
  }
}
