import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/control_section/card.dart';
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
        CallStatus.callIn => _createCallInWidget(child, context),
        CallStatus.callOut => _createCallOutWidget(child, context),
        CallStatus.talking => _createTalkingWidget(child, context),
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

  Widget _createTalkingWidget(Widget? child, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          const SizedBox(width: 8),
          child!,
          const SizedBox(width: 16),
          if (constraints.minWidth > 820) const Text('语音通话中'),
          const Spacer(),
          ControlCard(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Consumer<MuteMic>(
                  builder: (context, muteMic, child) => IconButton(
                    style: muteMic.value
                        ? const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.red),
                          )
                        : null,
                    color: muteMic.value ? Colors.white70 : null,
                    icon: Icon(muteMic.value ? Icons.mic_off : Icons.mic),
                    onPressed: () =>
                        Actions.invoke(context, MuteMicIntent(!muteMic.value)),
                  ),
                ),
                const SizedBox(width: 8),
                _NoiseSuppressWidget(),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ControlCard(
              child: Row(
            children: [
              const SizedBox(width: 8),
              Consumer<CallVolume>(
                builder: (context, callVolume, child) => IconButton(
                  icon: callVolume.isMute
                      ? const Icon(Icons.headset_off)
                      : const Icon(Icons.headset_mic),
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
              const SizedBox(width: 32),
            ],
          )),
          const SizedBox(width: 16),
          _createCallOperateButton(
            color: Colors.red,
            icon: Icons.call_end,
            onPressed: () => Actions.invoke(context, HangUpIntent()),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Row _createCallOutWidget(Widget? child, BuildContext context) {
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
          onPressed: () =>
              Actions.invoke(context, CancelCallingRequestIntent()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _createCallInWidget(Widget? child, BuildContext context) {
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

class _NoiseSuppressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MuteMic, CallNoiseSuppressionLevel>(
      builder: (context, muteMic, suppressLevel, child) => SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: 0,
            label: Text('闭麦'),
          ),
          ButtonSegment(
            value: 1,
            label: Text('原声'),
          ),
          ButtonSegment(
            value: 2,
            label: Text('弱降噪'),
          ),
          ButtonSegment(
            value: 3,
            label: Text('中降噪'),
          ),
          ButtonSegment(
            value: 4,
            label: Text('强降噪'),
          ),
        ],
        selected: {muteMic.value ? 0 : suppressLevel.value.index + 1},
        onSelectionChanged: (Set<int> newSelection) {
          final level = newSelection.first;
          if (level == 0) {
            Actions.invoke(context, const MuteMicIntent(true));
            return;
          }

          Actions.invoke(context, const MuteMicIntent(false));
          suppressLevel.value = NoiseSuppressionLevel.values[level - 1];
        },
      ),
    );
  }
}
