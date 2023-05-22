import 'dart:async';
import 'dart:math';

import 'package:bunga_player/common/im.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/video_progress_widget.dart';
import 'package:bunga_player/utils.dart';
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

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);

    _hideUITimer = RestartableTimer(const Duration(seconds: 3), () {
      setState(() {
        _isUIHidden = true;
      });
    });

    _adjectWindowSize();

    final iM = Provider.of<IM>(context, listen: false);
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

  @override
  Widget build(Object context) {
    final videoSection = VideoSection(
      onTap: _togglePlaying,
      onDoubleTap: _toggleFullscreen,
    );
    final controlSection = ControlSection(
      isFullScreen: _isFullScreen,
      onToggleFullScreenPressed: _toggleFullscreen,
      onVolumeSlideChanged: _setVolume,
      onTogglePlayingPressed: _togglePlaying,
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

  @override
  void onWindowResized() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isFullScreen) _adjectWindowSize();
    });
  }

  void _adjectWindowSize() async {
    final controller = VideoController.instance().videoPlayerController;
    if (controller == null) return;

    var videoRatio = controller.value.size.aspectRatio;
    var currentWidth = (await windowManager.getSize()).width;
    var titleHeight = await windowManager.getTitleBarHeight();

    var targetHeight = titleHeight +
        _roomSectionHeight +
        _controlSectionHeight +
        currentWidth / videoRatio;
    await windowManager.setSize(Size(currentWidth, targetHeight));
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
        final iM = Provider.of<IM>(context, listen: false);
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
      final iM = Provider.of<IM>(context, listen: false);
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
        child: Consumer<IM>(
          builder: (context, iM, child) {
            if (iM.watchers == null || iM.watchers!.length < 2) {
              return const SizedBox.shrink();
            }

            String text = '';
            for (var user in iM.watchers!) {
              if (user.name != iM.userName) {
                text += '${user.name}, ';
              }
            }

            if (text.length < 2) return const SizedBox.shrink();
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

class VideoSection extends StatelessWidget {
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  const VideoSection({
    super.key,
    this.onDoubleTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: onTap,
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

class ControlSection extends StatefulWidget {
  final bool isFullScreen;
  final VoidCallback? onTogglePlayingPressed;
  final ValueSetter<double>? onVolumeSlideChanged;
  final VoidCallback? onToggleFullScreenPressed;

  const ControlSection({
    super.key,
    required this.isFullScreen,
    this.onTogglePlayingPressed,
    this.onVolumeSlideChanged,
    this.onToggleFullScreenPressed,
  });
  @override
  State<ControlSection> createState() => _VideoControlState();
}

class _VideoControlState extends State<ControlSection> {
  bool _showTotalTime = true;

  @override
  Widget build(BuildContext context) {
    final controller = VideoController.instance();
    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            StreamBuilder(
              stream: controller.playerStatus.status.stream,
              builder: (context, snapshot) {
                bool isPlaying = controller.playerStatus.status.value ==
                    meedu.PlayerStatus.playing;
                return IconButton(
                  icon: isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                  iconSize: 36,
                  onPressed: widget.onTogglePlayingPressed,
                );
              },
            ),
            const SizedBox(width: 8),
            StreamBuilder(
              stream: controller.volume.stream,
              builder: (context, snapshot) {
                double volume = snapshot.data ?? controller.volume.value;
                return Row(
                  children: [
                    StreamBuilder(
                      stream: controller.mute.stream,
                      builder: (context, snapshot) {
                        bool isMute = snapshot.data ?? controller.mute.value;
                        return IconButton(
                          icon: isMute
                              ? const Icon(Icons.volume_mute)
                              : volume > 0.5
                                  ? const Icon(Icons.volume_up)
                                  : const Icon(Icons.volume_down),
                          onPressed: () => controller.setMute(!isMute),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor:
                              Theme.of(context).colorScheme.secondary,
                          thumbColor: Theme.of(context).colorScheme.secondary,
                          valueIndicatorColor:
                              Theme.of(context).colorScheme.secondary,
                          trackShape: SliderCustomTrackShape(),
                          showValueIndicator: ShowValueIndicator.always,
                        ),
                        child: Slider(
                          value: volume,
                          max: 1.0,
                          label: (volume * 100).toInt().toString(),
                          onChanged: widget.onVolumeSlideChanged,
                          focusNode: FocusNode(canRequestFocus: false),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            /*
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                logger.d('debug message!!');
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.subtitles),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            */
            IconButton(
              icon: widget.isFullScreen
                  ? const Icon(Icons.fullscreen_exit)
                  : const Icon(Icons.fullscreen),
              onPressed: widget.onToggleFullScreenPressed,
            ),
            const SizedBox(width: 8),
          ],
        ),
        Center(
          child: TextButton(
            child: StreamBuilder(
              stream: controller.position.stream,
              builder: (context, snapshot) {
                final duration = controller.duration.value;
                final position = snapshot.data ?? controller.position.value;
                final String positionString = dToHHmmss(position);

                final String displayString;
                if (_showTotalTime) {
                  final durationString = dToHHmmss(duration);
                  displayString = '$positionString / $durationString';
                } else {
                  final remainString = dToHHmmss(duration - position);
                  displayString = '$positionString - $remainString';
                }
                return Text(
                  displayString,
                  style: Theme.of(context).textTheme.labelMedium,
                );
              },
            ),
            onPressed: () => setState(() => _showTotalTime = !_showTotalTime),
          ),
        ),
      ],
    );
  }
}
