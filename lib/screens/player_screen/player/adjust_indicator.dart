import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class AdjustIndicator extends StatefulWidget {
  const AdjustIndicator({super.key});

  @override
  State<AdjustIndicator> createState() => _AdjustIndicatorState();
}

enum ChangedValue { brightness, volume, voiceVolume, micMute, lockScreen }

class _AdjustIndicatorState extends State<AdjustIndicator>
    with SingleTickerProviderStateMixin {
  final _visibleNotifier = AutoResetNotifier(const Duration(seconds: 1));
  ChangedValue? _changedValue = ChangedValue.brightness;

  late final _brightnessNotifier = context.read<ScreenBrightnessNotifier>();
  late final _volumeNotifier = getIt<PlayService>().volumeNotifier;
  late final _voiceNotifier = context.read<AgoraClient>().volumeNotifier;
  late final _micMuteNotifier = context.read<AgoraClient>().micMuteNotifier;
  late final _screenLockedNotifier = context.read<ScreenLockedNotifier>();

  late final _lockAnimationController = AnimationController(
    vsync: this,
    upperBound: 0.5,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void initState() {
    super.initState();

    _brightnessNotifier.addListener(_onChangeBrightness);
    _volumeNotifier.addListener(_onChangeVolume);
    _voiceNotifier.addListener(_onChangeVoiceVolume);
    _micMuteNotifier.addListener(_onChangeMicMute);
    _screenLockedNotifier.addListener(_onChangeLockScreen);

    _lockAnimationController;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_changedValue == ChangedValue.micMute) {
      return PopupWidget(
        visibleNotifier: _visibleNotifier,
        child: [
          Icon(
            _micMuteNotifier.value ? Icons.mic_off : Icons.mic,
            size: 60.0,
          ),
          Text(_micMuteNotifier.value ? '麦克已关闭' : '麦克已打开')
              .textColor(Colors.white)
              .padding(top: 12.0),
        ]
            .toColumn()
            .padding(horizontal: 12.0, vertical: 16.0)
            .card(color: colorScheme.tertiary.withAlpha(170)),
      );
    }

    if (_changedValue == ChangedValue.lockScreen) {
      _screenLockedNotifier.value
          ? _lockAnimationController.reverse()
          : _lockAnimationController.forward();
      return PopupWidget(
        visibleNotifier: _visibleNotifier,
        child: [
          Lottie.asset(
            'assets/images/lock.json',
            controller: _lockAnimationController,
          )
              .overflow(maxHeight: 80.0, minWidth: 80.0)
              .constrained(width: 60.0, height: 60.0),
          Text(_screenLockedNotifier.value ? '已锁屏' : '已解锁')
              .textColor(Colors.white)
              .padding(top: 12.0),
        ]
            .toColumn()
            .padding(horizontal: 12.0, vertical: 16.0)
            .card(color: colorScheme.tertiary.withAlpha(150)),
      );
    }

    final container = Card(
      clipBehavior: Clip.hardEdge,
      color: colorScheme.tertiary.withAlpha(150),
    );

    final leftIndicator = (_changedValue == ChangedValue.brightness
            ? ValueListenableBuilder(
                key: Key('brightness'),
                valueListenable: _brightnessNotifier,
                builder: (context, value, child) => _createIndicator(
                  icon: Icons.sunny,
                  value: value,
                ),
              )
            : ValueListenableBuilder(
                key: Key('volume'),
                valueListenable: _volumeNotifier,
                builder: (context, value, child) => _createIndicator(
                  icon: Icons.volume_up,
                  value: value.volume / 100.0,
                ),
              ))
        .animatedSwitcher(duration: const Duration(milliseconds: 175));

    final rightIndicator = ValueListenableBuilder(
      valueListenable: _voiceNotifier,
      builder: (context, value, child) => _createIndicator(
        icon: Icons.headphones,
        value: value.volume / 100.0,
      ),
    );

    const indicatorWidth = 60.0;
    final body = Consumer<CallStatus?>(
      builder: (context, value, child) {
        final showTalk = _changedValue != ChangedValue.brightness &&
          value == .talking;
        final hightlightTalk =
            showTalk && _changedValue == ChangedValue.voiceVolume;
        return [
          container.positioned(
            top: 0,
            bottom: 0,
            left: hightlightTalk ? indicatorWidth + 12.0 : 0,
            width: indicatorWidth,
            animate: true,
          ),
          leftIndicator
              .opacity(hightlightTalk ? 0.5 : 1.0, animate: true)
              .positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: indicatorWidth,
              ),
          if (showTalk)
            rightIndicator
                .opacity(hightlightTalk ? 1.0 : 0.5, animate: true)
                .positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: indicatorWidth,
                ),
        ]
            .toStack()
            .constrained(
              height: 168.0,
              width: showTalk ? indicatorWidth * 2 + 12.0 : indicatorWidth,
            )
            .animate(
              const Duration(milliseconds: 300),
              Curves.easeOutCubic,
            );
      },
    );

    return PopupWidget(
      visibleNotifier: _visibleNotifier,
      child: body,
    );
  }

  @override
  void dispose() {
    _visibleNotifier.dispose();

    _brightnessNotifier.removeListener(_onChangeBrightness);
    _volumeNotifier.removeListener(_onChangeVolume);
    _voiceNotifier.removeListener(_onChangeVoiceVolume);
    _micMuteNotifier.removeListener(_onChangeMicMute);
    _screenLockedNotifier.removeListener(_onChangeLockScreen);

    _lockAnimationController.dispose();

    super.dispose();
  }

  void _onChangeBrightness() {
    _visibleNotifier.mark();
    setState(() {
      _changedValue = ChangedValue.brightness;
    });
  }

  void _onChangeVolume() {
    if (context.read<ShouldShowHUDNotifier>().locks.contains('volume slider')) {
      return;
    }

    _visibleNotifier.mark();
    setState(() {
      _changedValue = ChangedValue.volume;
    });
  }

  void _onChangeVoiceVolume() {
    if (context.read<ShouldShowHUDNotifier>().locks.contains('voice slider')) {
      return;
    }
    _visibleNotifier.mark();
    setState(() {
      _changedValue = ChangedValue.voiceVolume;
    });
  }

  void _onChangeMicMute() {
    if (context.read<ShouldShowHUDNotifier>().locks.contains('call button')) {
      return;
    }
    _visibleNotifier.mark();
    setState(() {
      _changedValue = ChangedValue.micMute;
    });
  }

  void _onChangeLockScreen() {
    _visibleNotifier.mark();
    setState(() {
      _changedValue = ChangedValue.lockScreen;
    });
  }

  Widget _createIndicator({
    required IconData icon,
    required double value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      [
        Container(color: colorScheme.secondaryContainer),
        Container(color: colorScheme.primary)
            .constrained(height: value * 100.0),
      ]
          .toStack(alignment: .bottomCenter)
          .constrained(width: 18.0)
          .clipRRect(all: 12.0)
          .flexible(),
      Icon(icon).padding(top: 12.0),
    ]
        .toColumn()
        .padding(horizontal: 12.0, vertical: 16.0)
        .card(color: Colors.black12, elevation: 0);
  }
}
