import 'dart:async';
import 'dart:math';

import 'package:bunga_player/common/im.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/control_section.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart' as meedu;
import 'package:provider/provider.dart';
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
  final _roomSectionHeight = 36.0;
  final _controlSectionHeight = 64.0;
  bool _isFullScreen = false;

  bool _isUIHidden = false;
  late final RestartableTimer _hideUITimer;

  final _externalSubtitleSettings = ExternalSubtitleSettings();

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);

    _hideUITimer = RestartableTimer(const Duration(seconds: 3), () {
      setState(() {
        _isUIHidden = true;
      });
    });

    final iM = Provider.of<IMController>(context, listen: false);
    iM.askPosition();
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
    final videoSection = VideoSection(
      onTap: _togglePlaying,
      onDoubleTap: _toggleFullscreen,
      externalSubtitleSettings: _externalSubtitleSettings,
    );
    final controlSection = ControlSection(
      key: _controlSectionKey,
      isFullScreen: _isFullScreen,
      onToggleFullScreenPressed: _toggleFullscreen,
      onVolumeSlideChanged: _setVolume,
      onTogglePlayingPressed: _togglePlaying,
      externalSubtitleSettings: _externalSubtitleSettings,
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
                RoomSection(fixedHeight: _roomSectionHeight),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: _controlSectionHeight,
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xC0000000)),
                    child: controlSection,
                  ),
                ),
                Positioned(
                  bottom: _controlSectionHeight - 8,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoomSection(fixedHeight: _roomSectionHeight),
              Expanded(
                child: videoSection,
              ),
              SizedBox(
                height: _controlSectionHeight,
                child: controlSection,
              ),
            ],
          ),
          Positioned(
            bottom: _controlSectionHeight - 8,
            left: 0,
            right: 0,
            height: 16,
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
          _setFullScreen(false);
        },
      },
      child: Focus(
        autofocus: true,
        child: body,
      ),
    );
  }

  void _setFullScreen(bool isFullScreen) {
    windowManager.setFullScreen(isFullScreen);
  }

  void _toggleFullscreen() {
    _setFullScreen(!_isFullScreen);
  }

  void _togglePlaying() {
    final controller = VideoController.instance();
    controller.togglePlay().then((_) {
      Future.delayed(Duration.zero, () {
        final iM = Provider.of<IMController>(context, listen: false);
        iM.sendStatus();
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
      final iM = Provider.of<IMController>(context, listen: false);
      iM.sendStatus();
    });
  }
}

class RoomSection extends StatelessWidget {
  final double fixedHeight;

  const RoomSection({
    super.key,
    required this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fixedHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Consumer<IMController>(
          builder: (context, iM, child) {
            if (iM.watchers == null || iM.watchers!.isEmpty) {
              return const SizedBox.shrink();
            }

            String text = '';
            for (var user in iM.watchers!) {
              text += '${user.name}, ';
            }

            text = text.substring(0, text.length - 2);
            text += ' 在和你一起看';

            return Text(
              text,
              textAlign: TextAlign.left,
            );
          },
        ),
      ),
    );
  }
}

class VideoSection extends StatefulWidget {
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  final ExternalSubtitleSettings externalSubtitleSettings;

  const VideoSection({
    super.key,
    this.onDoubleTap,
    this.onTap,
    required this.externalSubtitleSettings,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  @override
  void initState() {
    super.initState();

    widget.externalSubtitleSettings.path.addListener(_onSubtitleChanged);
  }

  @override
  void dispose() {
    widget.externalSubtitleSettings.path.removeListener(_onSubtitleChanged);
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

  Future<void> _onSubtitleChanged() async {
    final subPath = widget.externalSubtitleSettings.path.value;
    if (subPath == 'NONE' || subPath == null) {
      return;
    }
    logger.i('Subtitle initial finished: $subPath');
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
