import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class CallControl extends StatefulWidget {
  const CallControl({super.key});

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
                _createCallOperateButton(
                  color: Colors.green,
                  icon: Icons.call,
                  onPressed: IMController().acceptCallAsking,
                ),
                const SizedBox(width: 16),
                _createCallOperateButton(
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
                _createCallOperateButton(
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
                _createCallOperateButton(
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
        onPressed: Navigator.of(context).pop,
      ),
    );
  }

  Widget _createCallOperateButton(
          {final VoidCallback? onPressed,
          required final Color color,
          required final IconData icon}) =>
      IconButton(
        style: ButtonStyle(
          fixedSize: const MaterialStatePropertyAll<Size>(Size(100, 36)),
          backgroundColor: MaterialStatePropertyAll<Color>(color),
        ),
        color: Colors.white70,
        icon: Icon(icon),
        onPressed: onPressed,
      );
}
