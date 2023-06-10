import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/popmoji_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/constants/constants.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:bunga_player/utils.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:window_manager/window_manager.dart';

enum ControlUIState {
  main,
  call,
  popmoji,
  subtitle,
  tune,
}

enum SubtitleControlUIState {
  delay,
  size,
  position,
}

class ControlSection extends StatefulWidget {
  final ValueNotifier<bool> isUIHidden;
  const ControlSection({super.key, required this.isUIHidden});
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  var _uiState = ControlUIState.main;

  final _callRinger = AudioPlayer();

  @override
  void initState() {
    super.initState();

    widget.isUIHidden.addListener(_onUIHiddenChanged);

    _callRinger.setSource(AssetSource('sounds/call.wav'));
    IMController().callStatus.addListener(_onCallStatusChanged);

    FullScreen().notifier.addListener(_onFullScreenChanged);
  }

  @override
  void dispose() {
    widget.isUIHidden.removeListener(_onUIHiddenChanged);
    IMController().callStatus.removeListener(_onCallStatusChanged);
    FullScreen().notifier.removeListener(_onFullScreenChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = IndexedStack(
      sizing: StackFit.expand,
      index: _uiState.index,
      children: [
        MainControl(
          onStateButtonPressed: (state) => setState(() {
            _uiState = state;
          }),
        ),
        CallControl(
          onBackPressed: () => setState(() {
            _uiState = ControlUIState.main;
          }),
        ),
        PopmojiControl(
          onBackPressed: () => setState(() {
            _uiState = ControlUIState.main;
          }),
        ),
        SubtitleControl(
          onBackPressed: () => setState(() {
            _uiState = ControlUIState.main;
          }),
        ),
        TuneControl(
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

  void _onUIHiddenChanged() {
    // When show again
    if (widget.isUIHidden.value == false) {
      setState(() {
        _uiState = ControlUIState.main;
      });
    }
  }

  void _onFullScreenChanged() async {
    // HACK: exit full screen makes layout a mass in Windows
    if (FullScreen().notifier.value == false) {
      var size = await windowManager.getSize();
      size += const Offset(1, 1);
      windowManager.setSize(size);
    }
  }
}

class MainControl extends StatelessWidget {
  final ValueSetter<ControlUIState> onStateButtonPressed;

  const MainControl({
    super.key,
    required this.onStateButtonPressed,
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
              onPressed: () => onStateButtonPressed(ControlUIState.call),
            ),
            const SizedBox(width: 8),

            // Popmoji Button
            IconButton(
              icon: const Icon(Icons.mood),
              onPressed: () => onStateButtonPressed(ControlUIState.popmoji),
            ),
            const SizedBox(width: 8),

            // Subtitle Button
            IconButton(
              icon: const Icon(Icons.subtitles),
              onPressed: () => onStateButtonPressed(ControlUIState.subtitle),
            ),
            const SizedBox(width: 8),

            // Tune button
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => onStateButtonPressed(ControlUIState.tune),
            ),
            const SizedBox(width: 8),

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

class PopmojiControl extends StatelessWidget {
  final VoidCallback onBackPressed;

  const PopmojiControl({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> emojiButtons = [];
    String? previousCode;
    for (var rune in Popmoji.emojis.runes) {
      var code = rune.toRadixString(16);
      if (code.length < 5) {
        if (previousCode == null) {
          previousCode = code;
        } else {
          code = '${previousCode}_$code';
          final svg = SvgPicture.asset(
            'assets/images/emojis/u$previousCode.svg',
            height: 24,
          );
          previousCode = null;

          emojiButtons.add(IconButton(
            icon: svg,
            onPressed: () {
              PopmojiController().send(code);
            },
          ));
        }
        continue;
      }

      final svg = SvgPicture.asset(
        'assets/images/emojis/u$code.svg',
        height: 24,
      );
      emojiButtons.add(IconButton(
        icon: svg,
        onPressed: () {
          PopmojiController().send(code);
          onBackPressed();
        },
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 8),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [...emojiButtons]),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class SubtitleControl extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SubtitleControl({
    super.key,
    required this.onBackPressed,
  });

  @override
  State<SubtitleControl> createState() => _SubtitleControlState();
}

class _SubtitleControlState extends State<SubtitleControl> {
  SubtitleControlUIState _subtitleUIState = SubtitleControlUIState.delay;

  @override
  Widget build(BuildContext context) {
    final listenable = {
      SubtitleControlUIState.delay: VideoController().subDelay,
      SubtitleControlUIState.size: VideoController().subSize,
      SubtitleControlUIState.position: VideoController().subPosition,
    }[_subtitleUIState]!;
    final minValue = {
      SubtitleControlUIState.delay: -10.0,
      SubtitleControlUIState.size: 20.0,
      SubtitleControlUIState.position: 0.0,
    }[_subtitleUIState]!;
    final maxValue = {
      SubtitleControlUIState.delay: 10.0,
      SubtitleControlUIState.size: 70.0,
      SubtitleControlUIState.position: 110.0,
    }[_subtitleUIState]!;
    final surfix = {
      SubtitleControlUIState.delay: 's',
      SubtitleControlUIState.size: 'px',
      SubtitleControlUIState.position: '%',
    }[_subtitleUIState]!;

    return Row(
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        const SizedBox(width: 8),

        // Subtitle dropbox
        MultiValueListenableBuilder(
          valueListenables: [
            VideoController().track,
            VideoController().tracks,
          ],
          builder: (context, values, child) {
            var subtitleTracks = (values[1] as Tracks?)?.subtitle;

            return SizedBox(
              width: 200,
              height: 36,
              child: ControlComboBox(
                items: [
                  ...subtitleTracks?.map((e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(() {
                              if (e.id == 'auto') return '默认';
                              if (e.id == 'no') return '无字幕';

                              String text = '[${e.id}]';
                              if (e.title != null) {
                                text += ' ${e.title}';
                              }
                              if (e.language != null) {
                                text += ' (${e.language})';
                              }
                              return text;
                            }()),
                          )) ??
                      [],
                  const DropdownMenuItem<String>(
                    value: 'OPEN',
                    child: Text('打开字幕……'),
                  ),
                ],
                value: values[0]?.subtitle.id,
                onChanged: (subtitleID) async {
                  if (subtitleID != 'OPEN') {
                    return VideoController().setSubtitleTrack(subtitleID);
                  }

                  final file = await openFile();
                  if (file != null) {
                    VideoController().addSubtitleTrack(file.path);
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(width: 16),

        // Subtitle adjust
        SegmentedButton<SubtitleControlUIState>(
          segments: const [
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.delay,
                label: Text('延迟'),
                icon: Icon(Icons.timer)),
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.size,
                label: Text('大小'),
                icon: Icon(Icons.format_size)),
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.position,
                label: Text('位置'),
                icon: Icon(Icons.height)),
          ],
          selected: <SubtitleControlUIState>{_subtitleUIState},
          onSelectionChanged: (Set<SubtitleControlUIState> newSelection) {
            setState(() {
              _subtitleUIState = newSelection.first;
            });
          },
        ),
        const SizedBox(width: 16),
        ValueListenableBuilder<double>(
          valueListenable: listenable,
          builder: (context, value, child) {
            final textController =
                TextEditingController(text: value.toStringAsFixed(1));
            var child = Row(
              children: [
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: Slider(
                      value: value < minValue
                          ? minValue
                          : value > maxValue
                              ? maxValue
                              : value,
                      max: maxValue,
                      min: minValue,
                      onChanged: (value) => listenable.value = value,
                      focusNode: FocusNode(canRequestFocus: false),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 64,
                  height: 32,
                  child: TextField(
                    cursorHeight: 16,
                    style: Theme.of(context).textTheme.bodySmall,
                    controller: textController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.-]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final newValueText = newValue.text;
                        if (newValueText == "-" ||
                            newValueText == "-." ||
                            newValueText == ".") {
                          // Returning new value if text field contains only "." or "-." or ".".
                          return newValue;
                        } else if (newValueText.isNotEmpty) {
                          // If text filed not empty and value updated then trying to parse it as a double.
                          try {
                            double.parse(newValueText);
                            // Here double parsing succeeds so returning that new value.
                            return newValue;
                          } catch (e) {
                            // Here double parsing failed so returning that old value.
                            return oldValue;
                          }
                        } else {
                          // Returning new value if text field was empty.
                          return newValue;
                        }
                      }),
                    ],
                    onTap: () {
                      textController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: textController.text.length,
                      );
                    },
                    onEditingComplete: () =>
                        listenable.value = double.parse(textController.text),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: const OutlineInputBorder(),
                      suffix: Text(surfix),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  iconSize: 16.0,
                  onPressed: listenable.reset,
                ),
              ],
            );
            return Expanded(child: child);
          },
        ),
      ],
    );
  }
}

class TuneControl extends StatelessWidget {
  final VoidCallback onBackPressed;

  const TuneControl({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 8),

        // Contrast button
        ControlCard(
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Text('视频亮度'),
              const SizedBox(width: 12),
              ValueListenableBuilder(
                valueListenable: VideoController().contrast,
                builder: (context, contrast, child) => SizedBox(
                  width: 100,
                  child: Slider(
                    value: contrast.toDouble(),
                    max: 100,
                    min: -30,
                    label: '$contrast%',
                    onChanged: (value) =>
                        VideoController().contrast.value = value.toInt(),
                    focusNode: FocusNode(canRequestFocus: false),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                iconSize: 16.0,
                onPressed: VideoController().contrast.reset,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Audio tracks section
        ControlCard(
          child: MultiValueListenableBuilder(
            valueListenables: [
              VideoController().track,
              VideoController().tracks,
            ],
            builder: (context, values, child) {
              var audioTracks = values[1]?.audio as List<AudioTrack>?;

              return Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('音频轨道'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: ControlComboBox(
                      items: audioTracks
                              ?.map((e) => DropdownMenuItem<String>(
                                    value: e.id,
                                    child: Text(() {
                                      if (e.id == 'auto') return '默认';
                                      if (e.id == 'no') return '无声音';

                                      String text = '[${e.id}]';
                                      if (e.title != null) {
                                        text += ' ${e.title}';
                                      }
                                      if (e.language != null) {
                                        text += ' (${e.language})';
                                      }
                                      return text;
                                    }()),
                                  ))
                              .toList() ??
                          [],
                      value: values[0]?.audio.id,
                      onChanged: VideoController().setAudioTrack,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ControlCard extends StatelessWidget {
  final Widget child;

  const ControlCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceTint.withAlpha(0x1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class ControlComboBox extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final ValueSetter<String?> onChanged;

  const ControlComboBox({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: items,
          value: value,
          onChanged: onChanged,
          padding: const EdgeInsets.only(
            left: 12,
            right: 4,
            top: 8,
            bottom: 8,
          ),
          borderRadius: BorderRadius.circular(4),
          style: Theme.of(context).textTheme.bodyMedium,
          isExpanded: true,
          isDense: true,
          itemHeight: null,
          focusColor: Colors.transparent,
          selectedItemBuilder: (context) => items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(
                    (e.child as Text).data!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
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
