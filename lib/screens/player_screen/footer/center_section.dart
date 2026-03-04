import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/screens/player_screen/footer/danmaku_control.dart';
import 'package:bunga_player/utils/business/preference_notifier.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

class CenterSection extends StatefulWidget {
  const CenterSection({super.key});

  @override
  State<CenterSection> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<CenterSection> {
  late final _danmakuControl = DanmakuControl(key: Key('danmaku'));
  @override
  Widget build(BuildContext context) {
    return Consumer<DanmakuVisible>(
      builder: (context, visible, child) {
        return (visible.value
                ? _danmakuControl
                : _DurationButton().center(key: Key('duration')))
            .animatedSwitcher(duration: const Duration(milliseconds: 300));
      },
    );
  }
}

class _DurationButton extends StatefulWidget {
  const _DurationButton();

  @override
  State<_DurationButton> createState() => _DurationButtonState();
}

class _DurationButtonState extends State<_DurationButton> {
  final _showRemainNotifier = createPreferenceNotifier(
    key: 'show_remain_duration',
    initValue: false,
  );

  @override
  void dispose() {
    _showRemainNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playService = MediaPlayer.i;
    return ListenableBuilder(
      listenable: Listenable.merge([
        playService.positionNotifier,
        playService.durationNotifier,
        _showRemainNotifier,
      ]),
      builder: (context, child) {
        final position = playService.positionNotifier.value;
        final duration = playService.durationNotifier.value;
        final displayString = _showRemainNotifier.value
            ? '${position.hhmmss} - ${max(duration - position, Duration.zero).hhmmss}'
            : '${position.hhmmss} / ${duration.hhmmss}';
        return TextButton(
          onPressed: _showRemainNotifier.toggle,
          child: Text(
            displayString,
          ).textStyle(Theme.of(context).textTheme.labelMedium!),
        );
      },
    );
  }
}
