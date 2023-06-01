import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:bunga_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

enum ControlUIState {
  main,
  call,
}

class ControlSection extends StatefulWidget {
  const ControlSection({super.key});
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  var _uiState = ControlUIState.main;

  final _callRinger = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _callRinger.setSource(AssetSource('sounds/call.wav'));
    IMController().callStatus.addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    IMController().callStatus.removeListener(_onCallStatusChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = IndexedStack(
      sizing: StackFit.expand,
      index: _uiState.index,
      children: [
        MainControl(
          onCallPressed: () => setState(() {
            _uiState = ControlUIState.call;
          }),
        ),
        CallControl(
          onBackPressed: () => setState(() {
            _uiState = ControlUIState.main;
          }),
        ),
      ],
    );

    body = SliderTheme(
      data: SliderThemeData(
        activeTrackColor: Theme.of(context).colorScheme.secondary,
        thumbColor: Theme.of(context).colorScheme.secondary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        valueIndicatorColor: Theme.of(context).colorScheme.secondary,
        trackShape: SliderCustomTrackShape(),
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: body,
    );

    return body;
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
    if (callStatus == CallStatus.callIn || callStatus == CallStatus.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
    }
  }
}

class MainControl extends StatelessWidget {
  final VoidCallback onCallPressed;

  const MainControl({
    super.key,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            // Play button
            ValueListenableBuilder(
              valueListenable: VideoController().isPlaying,
              builder: (context, isPlaying, child) => IconButton(
                icon: isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                iconSize: 36,
                onPressed: VideoController().togglePlay,
              ),
            ),
            const SizedBox(width: 8),

            // Volume section
            ValueListenableBuilder(
              valueListenable: VideoController().isMute,
              builder: (context, isMute, child) => IconButton(
                icon: isMute
                    ? const Icon(Icons.volume_mute)
                    : const Icon(Icons.volume_up),
                onPressed: () => VideoController().isMute.value = !isMute,
              ),
            ),
            const SizedBox(width: 8),
            MultiValueListenableBuilder(
              valueListenables: [
                VideoController().volume,
                VideoController().isMute,
              ],
              builder: (context, values, child) => SizedBox(
                width: 100,
                child: Slider(
                  value: values[1] ? 0.0 : values[0],
                  max: 100.0,
                  label: '${values[0].toInt()}%',
                  onChanged: (value) => VideoController().volume.value = value,
                  focusNode: FocusNode(canRequestFocus: false),
                ),
              ),
            ),
            const Spacer(),

            // Call Button
            CallButton(
              onPressed: onCallPressed,
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
                  onPressed: () {
                    final player = VideoController().player;
                    final mpvPlayer = player.platform as libmpvPlayer;
                    final mpv = mpvPlayer.mpv;

                    final command =
                        'sub-add /Users/lianghanzhong/Movies/柠檬糖小孩/aaa.srt'
                            .toNativeUtf8();
                    mpv.mpv_command_string(mpvPlayer.ctx, command.cast());
                    calloc.free(command);
                  },
                ),
                const SizedBox(width: 8),
*/

            // Full screen button
            ValueListenableBuilder(
              valueListenable: FullScreen().notifier,
              builder: (context, isFullScreen, child) => IconButton(
                icon: isFullScreen
                    ? const Icon(Icons.fullscreen_exit)
                    : const Icon(Icons.fullscreen),
                onPressed: FullScreen().toggle,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const Center(child: DurationButton()),
      ],
    );
  }
}

class CallControl extends StatefulWidget {
  final VoidCallback onBackPressed;

  const CallControl({
    super.key,
    required this.onBackPressed,
  });

  @override
  State<CallControl> createState() => _CallControlState();
}

class _CallControlState extends State<CallControl> {
  final _voiceVolume = ValueNotifier<int>(100);
  final _voiceMute = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _voiceVolume.addListener(() {
      IMController().setVoiceVolume(_voiceVolume.value);
    });
    _voiceMute.addListener(() {
      IMController().setVoiceVolume(_voiceMute.value ? 0 : _voiceVolume.value);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                MultiValueListenableBuilder(
                  valueListenables: [
                    _voiceVolume,
                    _voiceMute,
                  ],
                  builder: (context, values, child) => SizedBox(
                    width: 100,
                    child: Slider(
                      value: values[1] ? 0 : values[0].toDouble(),
                      max: 200,
                      divisions: 200,
                      label: '${values[0]}%',
                      onChanged: (value) {
                        _voiceMute.value = false;
                        _voiceVolume.value = value.toInt();
                      },
                      focusNode: FocusNode(canRequestFocus: false),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
        onPressed: widget.onBackPressed,
      ),
    );
  }
}

class DurationButton extends StatefulWidget {
  const DurationButton({super.key});

  @override
  State<DurationButton> createState() => _DurationButtonState();
}

class _DurationButtonState extends State<DurationButton> {
  bool _showTotalTime = true;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: MultiValueListenableBuilder(
        valueListenables: [
          VideoController().position,
          VideoController().duration,
        ],
        builder: (context, values, child) {
          final String positionString = dToHHmmss(values[0]);

          final String displayString;
          if (_showTotalTime) {
            final durationString = dToHHmmss(values[1]);
            displayString = '$positionString / $durationString';
          } else {
            final remainString = dToHHmmss(values[1] - values[0]);
            displayString = '$positionString - $remainString';
          }
          return Text(
            displayString,
            style: Theme.of(context).textTheme.labelMedium,
          );
        },
      ),
      onPressed: () => setState(() => _showTotalTime = !_showTotalTime),
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
