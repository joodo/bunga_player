import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/actions.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/screens/widgets/loading_text.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/divider.dart';

class CallControl extends StatefulWidget {
  const CallControl({super.key});

  @override
  State<CallControl> createState() => _CallControlState();
}

class _CallControlState extends State<CallControl> {
  @override
  Widget build(BuildContext context) {
    return Selector<VoiceCallStatus, VoiceCallStatusType>(
      selector: (context, currentCallStatus) => currentCallStatus.value,
      builder: (context, callStatus, child) => switch (callStatus) {
        VoiceCallStatusType.callIn => _createCallInWidget(child, context),
        VoiceCallStatusType.callOut => _createCallOutWidget(child, context),
        VoiceCallStatusType.talking => _createTalkingWidget(child, context),
        VoiceCallStatusType.none => Builder(
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
          if (constraints.minWidth > 850) const Text('语音通话中'),
          const Spacer(),

          // Mic control
          Consumer<VoiceCallMuteMic>(
            builder: (context, muteMic, child) => IconButton(
              style: muteMic.value
                  ? const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.red),
                    )
                  : null,
              color: muteMic.value ? Colors.white70 : null,
              icon: Icon(muteMic.value ? Icons.mic_off : Icons.mic),
              onPressed: () => Actions.invoke(
                  context, VoiceCallMuteMicIntent(!muteMic.value)),
            ),
          ),
          const SizedBox(width: 8),
          _NoiseSuppressWidget(),
          const SizedBox(width: 8),

          // Call control
          const ControlDivider(),
          Consumer<VoiceCallVolume>(
            builder: (context, callVolume, child) => IconButton(
              icon: callVolume.value.mute
                  ? const Icon(Icons.headset_off)
                  : const Icon(Icons.headset_mic),
              onPressed: () =>
                  callVolume.value = callVolume.value.copyWithToggleMute(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<VoiceCallVolume>(
            builder: (context, callVolume, child) => SizedBox(
              width: 100,
              child: mock.MySlider(
                useRootOverlay: true,
                max: Volume.max.toDouble(),
                min: Volume.min.toDouble(),
                divisions: Volume.max - Volume.min,
                value: callVolume.value.mute
                    ? Volume.min.toDouble()
                    : callVolume.value.volume.toDouble(),
                label: '${callVolume.value.volume}%',
                onChanged: (value) {
                  callVolume.value = Volume(
                    volume: value.toInt(),
                  );
                },
                focusNode: FocusNode(canRequestFocus: false),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _createCallOperateButton(
            color: Colors.red,
            icon: Icons.call_end,
            onPressed: () => Actions.invoke(context, const HangUpIntent()),
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
        const LoadingText('正在等待接听'),
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
        const Text('收到语音通话请求').breath(),
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
          fixedSize: const WidgetStatePropertyAll<Size>(Size(100, 36)),
          backgroundColor: WidgetStatePropertyAll<Color>(color),
        ),
        color: Colors.white70,
        icon: Icon(icon),
        onPressed: onPressed,
      );
}

class _NoiseSuppressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<VoiceCallMuteMic, VoiceCallNoiseSuppressionLevel>(
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
            Actions.invoke(context, const VoiceCallMuteMicIntent(true));
            return;
          }

          Actions.invoke(context, const VoiceCallMuteMicIntent(false));
          suppressLevel.value = NoiseSuppressionLevel.values[level - 1];
        },
      ),
    );
  }
}
