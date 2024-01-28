import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/providers/voice_call.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

class CallControl extends StatefulWidget {
  const CallControl({super.key});

  @override
  State<CallControl> createState() => _CallControlState();
}

class _CallControlState extends State<CallControl> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceCall>(
      builder: (context, voiceCall, child) => switch (voiceCall.callStatus) {
        CallStatus.callIn => Row(
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
                onPressed: voiceCall.acceptAsking,
              ),
              const SizedBox(width: 16),
              _createCallOperateButton(
                color: Colors.red,
                icon: Icons.call_end,
                onPressed: voiceCall.rejectAsking,
              ),
              const SizedBox(width: 16),
            ],
          ),
        CallStatus.callOut => Row(
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
                onPressed: voiceCall.cancelAsking,
              ),
              const SizedBox(width: 16),
            ],
          ),
        CallStatus.calling => Row(
            children: [
              const SizedBox(width: 8),
              child!,
              const SizedBox(width: 16),
              const Text('语音通话中'),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: voiceCall.mute,
                builder: (context, isMute, child) => IconButton(
                  icon: isMute
                      ? const Icon(Icons.volume_mute)
                      : const Icon(Icons.volume_up),
                  onPressed: () => voiceCall.mute.value = !isMute,
                ),
              ),
              const SizedBox(width: 8),
              MultiValueListenableBuilder(
                valueListenables: [
                  voiceCall.volume,
                  voiceCall.mute,
                ],
                builder: (context, values, child) => SizedBox(
                  width: 100,
                  child: mock.MySlider(
                    useRootOverlay: true,
                    value: values[1] ? 0 : values[0].toDouble(),
                    max: 200,
                    divisions: 200,
                    label: '${values[0]}%',
                    onChanged: (value) {
                      voiceCall.mute.value = false;
                      voiceCall.volume.value = value.toInt();
                    },
                    focusNode: FocusNode(canRequestFocus: false),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _createCallOperateButton(
                color: Colors.red,
                icon: Icons.call_end,
                onPressed: voiceCall.hangUp,
              ),
              const SizedBox(width: 16),
            ],
          ),
        CallStatus.none => Builder(
            builder: (context) {
              Future.microtask(Navigator.of(context).pop);
              return const SizedBox.shrink();
            },
          ),
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
