import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:bunga_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart' as meedu;
import 'package:window_manager/window_manager.dart';

enum ControlUIState {
  main,
  call,
}

SliderThemeData sliderThemeData(context, {double thumbRadius = 10}) {
  return SliderThemeData(
    activeTrackColor: Theme.of(context).colorScheme.secondary,
    thumbColor: Theme.of(context).colorScheme.secondary,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
    valueIndicatorColor: Theme.of(context).colorScheme.secondary,
    trackShape: SliderCustomTrackShape(),
    showValueIndicator: ShowValueIndicator.always,
  );
}

class ControlSection extends StatefulWidget {
  const ControlSection({super.key});
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  var _uiState = ControlUIState.main;

  // for state main
  bool _showTotalTime = true;

  // for voice
  final _voiceVolume = ValueNotifier<int>(100);
  final _voiceMute = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    final player = AudioPlayer(playerId: 'voice_call');
    player.setSource(AssetSource('sounds/call.wav'));
    IMController().callStatus.addListener(_onCallStatusChanged);

    // for call
    _voiceVolume.addListener(() {
      IMController().setVoiceVolume(_voiceVolume.value);
    });
    _voiceMute.addListener(() {
      IMController().setVoiceVolume(_voiceMute.value ? 0 : _voiceVolume.value);
    });
  }

  @override
  void dispose() {
    IMController().callStatus.removeListener(_onCallStatusChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = VideoController.instance();

    switch (_uiState) {
      case ControlUIState.main:
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
                      onPressed: () {
                        final controller = VideoController.instance();
                        controller.togglePlay().then((_) {
                          Future.delayed(Duration.zero, () {
                            IMController().sendStatus();
                          });
                        });
                      },
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
                            bool isMute =
                                snapshot.data ?? controller.mute.value;
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
                            data: sliderThemeData(context),
                            child: Slider(
                              value: volume,
                              max: 1.0,
                              label: (volume * 100).toInt().toString(),
                              onChanged: (value) {
                                final controller = VideoController.instance();
                                controller.setMute(false);
                                controller.setVolume(volume);
                              },
                              focusNode: FocusNode(canRequestFocus: false),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                CallButton(
                  onPressed: () => setState(() {
                    _uiState = ControlUIState.call;
                  }),
                ),
                const SizedBox(width: 8),
                /*
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.subtitles),
                  onPressed: () => setState(() {
                    _uiState = ControlUIState.subtitle;
                  }),
                ),
                const SizedBox(width: 8),
            */
                const FullScreenButtton(),
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
                onPressed: () =>
                    setState(() => _showTotalTime = !_showTotalTime),
              ),
            ),
          ],
        );

      case ControlUIState.call:
        return ValueListenableBuilder(
          valueListenable: IMController().callStatus,
          builder: (context, callStatus, child) {
            switch (IMController().callStatus.value) {
              case CallStatus.callIn:
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    child!,
                    const SizedBox(width: 16),
                    AnimatedTextKit(
                      animatedTexts: [FadeAnimatedText('收到语音通话请求')],
                      repeatForever: true,
                      pause: Duration.zero,
                    ),
                    const Spacer(),
                    CallOperationalButton(
                      color: Colors.green,
                      icon: Icons.call,
                      onPressed: IMController().acceptCallAsking,
                    ),
                    const SizedBox(width: 16),
                    CallOperationalButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      onPressed: IMController().rejectCallAsking,
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              case CallStatus.callOut:
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    child!,
                    const SizedBox(width: 16),
                    const Text('正在等待接听'),
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          '...',
                          speed: const Duration(milliseconds: 500),
                        )
                      ],
                      repeatForever: true,
                      pause: const Duration(milliseconds: 500),
                    ),
                    const Spacer(),
                    CallOperationalButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      onPressed: IMController().cancelCallAsking,
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              case CallStatus.calling:
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    child!,
                    const SizedBox(width: 16),
                    const Text('语音通话中'),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _voiceMute,
                      builder: (context, isMute, child) => IconButton(
                        icon: isMute
                            ? const Icon(Icons.volume_mute)
                            : const Icon(Icons.volume_up),
                        onPressed: () => _voiceMute.value = !isMute,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: _voiceVolume,
                      builder: (context, volume, child) =>
                          ValueListenableBuilder(
                        valueListenable: _voiceMute,
                        builder: (context, isMute, child) => SizedBox(
                          width: 100,
                          child: SliderTheme(
                            data: sliderThemeData(context),
                            child: Slider(
                              value: isMute ? 0 : volume.toDouble(),
                              max: 200,
                              divisions: 200,
                              label: volume.toString(),
                              onChanged: (value) {
                                _voiceMute.value = false;
                                _voiceVolume.value = value.toInt();
                              },
                              focusNode: FocusNode(canRequestFocus: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CallOperationalButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      onPressed: IMController().hangUpCall,
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              default:
                return const SizedBox.shrink();
            }
          },
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() {
              _uiState = ControlUIState.main;
            }),
          ),
        );
    }
  }

  void _onCallStatusChanged() {
    final callStatus = IMController().callStatus.value;

    // Control section UI
    switch (callStatus) {
      case CallStatus.none:
        if (_uiState == ControlUIState.call) {
          setState(() {
            _uiState = ControlUIState.main;
          });
        }
        break;
      case CallStatus.callIn:
        setState(() {
          _uiState = ControlUIState.call;
        });
        break;
      default:
        {}
    }

    // Play sound when call in or out
    final player = AudioPlayer(playerId: 'voice_call');
    if (callStatus == CallStatus.callIn || callStatus == CallStatus.callOut) {
      player.resume();
    } else {
      player.stop();
    }
  }
}

class FullScreenButtton extends StatefulWidget {
  const FullScreenButtton({super.key});

  @override
  State<FullScreenButtton> createState() => _FullScreenButttonState();
}

class _FullScreenButttonState extends State<FullScreenButtton>
    with WindowListener {
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
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
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isFullScreen
          ? const Icon(Icons.fullscreen_exit)
          : const Icon(Icons.fullscreen),
      onPressed: () => windowManager.setFullScreen(!_isFullScreen),
    );
  }
}

class CallOperationalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final IconData icon;

  const CallOperationalButton({
    super.key,
    this.onPressed,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        fixedSize: const MaterialStatePropertyAll<Size>(Size(100, 36)),
        backgroundColor: MaterialStatePropertyAll<Color>(color),
      ),
      color: Colors.white70,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

class CallButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const CallButton({
    super.key,
    this.onPressed,
  });

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    upperBound: 0.2,
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceInOut,
  );

  @override
  void dispose() {
    // FIXME: keep jumping "Looking up a deactivated widget's ancestor is unsafe"
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: IMController().callStatus,
      builder: (context, callStatus, child) {
        switch (callStatus) {
          case CallStatus.none:
            return IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                IMController().startCallAsking();
                widget.onPressed?.call();
              },
            );
          case CallStatus.callOut:
          case CallStatus.calling:
            return IconButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              color: Colors.white70,
              icon: const Icon(Icons.call),
              onPressed: widget.onPressed,
            );
          case CallStatus.callIn:
            return RotationTransition(
              turns: _animation,
              child: IconButton(
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.green),
                ),
                color: Colors.white70,
                icon: const Icon(Icons.call),
                onPressed: widget.onPressed,
              ),
            );
        }
      },
    );
  }
}
