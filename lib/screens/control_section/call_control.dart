import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/utils/volume_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallControl extends StatefulWidget {
  const CallControl({super.key});

  @override
  State<CallControl> createState() => _CallControlState();
}

class _CallControlState extends State<CallControl> {
  @override
  Widget build(BuildContext context) {
    return Selector<CurrentCallStatus, CallStatus>(
      selector: (context, currentCallStatus) => currentCallStatus.value,
      builder: (context, callStatus, child) => switch (callStatus) {
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
                onPressed: () =>
                    Actions.invoke(context, AcceptCallingRequestIntent()),
              ),
              const SizedBox(width: 16),
              _createCallOperateButton(
                color: Colors.red,
                icon: Icons.call_end,
                onPressed: () =>
                    Actions.invoke(context, RejectCallingRequestIntent()),
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
                onPressed: () =>
                    Actions.invoke(context, CancelCallingRequestIntent()),
              ),
              const SizedBox(width: 16),
            ],
          ),
        CallStatus.talking => Row(
            children: [
              const SizedBox(width: 8),
              child!,
              const SizedBox(width: 16),
              const Text('语音通话中'),
              const Spacer(),
              Consumer<CallVolume>(
                builder: (context, callVolume, child) => IconButton(
                  icon: callVolume.isMute
                      ? const Icon(Icons.volume_mute)
                      : const Icon(Icons.volume_up),
                  onPressed: () => callVolume.isMute = !callVolume.isMute,
                ),
              ),
              const SizedBox(width: 8),
              Consumer<CallVolume>(
                builder: (context, callVolume, child) => SizedBox(
                  width: 100,
                  child: mock.MySlider(
                    useRootOverlay: true,
                    max: VolumeNotifier.maxVolume.toDouble(),
                    min: VolumeNotifier.minVolume.toDouble(),
                    divisions:
                        VolumeNotifier.maxVolume - VolumeNotifier.minVolume,
                    value: callVolume.isMute
                        ? VolumeNotifier.minVolume.toDouble()
                        : callVolume.volume.toDouble(),
                    label: '${callVolume.volume}%',
                    onChanged: (value) {
                      callVolume.isMute = false;
                      callVolume.volume = value.toInt();
                    },
                    focusNode: FocusNode(canRequestFocus: false),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _createCallOperateButton(
                color: Colors.red,
                icon: Icons.call_end,
                onPressed: () => Actions.invoke(context, HangUpIntent()),
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
