import 'dart:async';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/voice_call/client/client.dart';

/// Indicator shows when adjusting volume, brightness etc.
class AdjustIndicator extends StatefulWidget {
  const AdjustIndicator({super.key});

  @override
  State<AdjustIndicator> createState() => _AdjustIndicatorState();
}

class _AdjustIndicatorState extends State<AdjustIndicator>
    with SingleTickerProviderStateMixin {
  final _visibleNotifier = AutoResetNotifier(const Duration(seconds: 2));

  late final _lockAnimationController = AnimationController(
    vsync: this,
    upperBound: 0.5,
    duration: const Duration(milliseconds: 300),
  );

  final _eventTypeNotifier = ValueNotifier<AdjustIndicatorEventType?>(null);
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _lockAnimationController;

    _subscription = context.read<AdjustIndicatorEvent>().listen((newType) {
      _eventTypeNotifier.value = newType;
      _visibleNotifier.mark();
    });
  }

  @override
  void dispose() {
    _visibleNotifier.dispose();
    _eventTypeNotifier.dispose();

    _lockAnimationController.dispose();

    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _eventTypeNotifier,
      builder: (context, eventType, child) {
        final content = switch (eventType) {
          .micMute => _createMicMuteWidget(),
          .lockScreen => _createLockScreenWidget(),
          .brightness => _createBrightnessWidget(),
          .volume => _createVolumeWidget(),
          .voiceVolume => _createVoiceVolumeWidget(),
          .mediaVolume => _createMediaVolumeWidget(),
          null => null,
        };

        return ValueListenableBuilder(
          valueListenable: _visibleNotifier,
          builder: (context, visible, child) => PopupWidget(
            showing: visible,
            layoutBuilder: (context, child) =>
                child.padding(left: 12.0).alignment(Alignment.centerLeft),
            child:
                AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  child:
                      content
                          ?.padding(horizontal: 12.0, vertical: 16.0)
                          .constrained(animate: true) ??
                      const SizedBox.shrink(),
                ).card(
                  color: Theme.of(context).colorScheme.tertiary.withAlpha(170),
                ),
          ),
        );
      },
    );
  }

  Widget? _createLockScreenWidget() {
    final notifier = context.read<ScreenLockedNotifier>();
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isLock, child) {
        notifier.value
            ? _lockAnimationController.reverse()
            : _lockAnimationController.forward();
        return _createIconIndicator(
          icon: Lottie.asset(
            'assets/images/lock.json',
            controller: _lockAnimationController,
          ).overflow(maxHeight: 80.0, minWidth: 80.0),
          text: notifier.value ? '已锁屏' : '已解锁',
        );
      },
    );
  }

  Widget? _createMicMuteWidget() {
    final notifier = context.read<VoiceCallClient?>()?.micMuteNotifier;
    if (notifier == null) return null;
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isMute, child) {
        return _createIconIndicator(
          icon: Icon(isMute ? Icons.mic_off : Icons.mic, size: 60.0),
          text: isMute ? '麦克已关闭' : '麦克已打开',
        );
      },
    );
  }

  Widget? _createBrightnessWidget() {
    final notifier = context.read<ScreenBrightnessNotifier>();
    return ValueListenableBuilder(
      key: Key('brightness'),
      valueListenable: notifier,
      builder: (context, value, child) =>
          _createProgressIndicator(icon: Icons.sunny, value: value),
    );
  }

  Widget? _createVolumeWidget() {
    final notifier = context.read<MediaVolumeNotifier>();
    return ValueListenableBuilder(
      key: Key('volume'),
      valueListenable: notifier,
      builder: (context, value, child) =>
          _createProgressIndicator(icon: Icons.volume_up, value: value.level),
    );
  }

  Widget? _createVoiceVolumeWidget() {
    final notifier = context.read<VoiceCallClient?>()?.volumeNotifier;
    if (notifier == null) return null;
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) =>
          _createProgressIndicator(icon: Icons.voice_chat, value: value.level),
    );
  }

  Widget? _createMediaVolumeWidget() {
    final notifier = getIt<PlayService>().volumeNotifier;
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, volume, child) =>
          _createProgressIndicator(icon: Icons.music_note, value: volume.level),
    );
  }

  Widget _createIconIndicator({required Widget icon, required String text}) {
    const iconSize = 60.0;
    return [
      icon.constrained(width: iconSize, height: iconSize),
      Text(text).textColor(Colors.white).padding(top: 12.0),
    ].toColumn(mainAxisSize: .min);
  }

  Widget _createProgressIndicator({
    required IconData icon,
    required double value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const progressHeight = 120.0;
    return [
      LayoutBuilder(
        builder: (context, constraints) => [
          Container(
            color: colorScheme.secondaryContainer,
          ).constrained(height: progressHeight),
          Container(color: colorScheme.primary)
              .constrained(height: value * progressHeight, animate: true)
              .animate(const Duration(milliseconds: 150), Curves.easeOutCubic),
        ].toStack(alignment: .bottomCenter),
      ).constrained(width: 18.0).clipRRect(all: 12.0).flexible(),
      Icon(icon).padding(top: 12.0),
    ].toColumn(mainAxisSize: .min);
  }
}
