import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/wrappers/theme.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

import '../actions.dart';
import '../business.dart';

class SavedPositionHint extends StatefulWidget {
  const SavedPositionHint({super.key});

  @override
  State<SavedPositionHint> createState() => _SavedPositionHintState();
}

class _SavedPositionHintState extends State<SavedPositionHint>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    value: 0.0,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 75),
    vsync: this,
  )..addStatusListener((AnimationStatus status) {
      setState(() {});
    });

  late final _savedPositionNotifier = context.read<SavedPositionNotifier>();
  late final _positionNotifier = getIt<PlayService>().positionNotifier;

  @override
  void initState() {
    _savedPositionNotifier.addListener(_updateAnimation);
    _positionNotifier.addListener(_updateAnimation);

    super.initState();
  }

  @override
  void dispose() {
    _savedPositionNotifier.removeListener(_updateAnimation);
    _positionNotifier.removeListener(_updateAnimation);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedPosition = _savedPositionNotifier.value ?? Duration.zero;
    final card = [
      Text('上回看到 ${savedPosition.hhmmss}').padding(vertical: 12.0, left: 16.0),
      TextButton(
        onPressed: () {
          Actions.invoke(context, SeekIntent(savedPosition));
          _hide();
        },
        child: const Text('跳转'),
      ).padding(left: 8.0),
      StyledWidget(IconButton(
        onPressed: _hide,
        icon: const Icon(Icons.close),
      )).padding(right: 8.0),
    ]
        .toRow()
        .card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
        )
        // FIXME: Deal with theme..toast...action
        .colorScheme(
            seedColor: ThemeWrapper.seedColor, brightness: Brightness.light);

    final animedCard = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return FadeScaleTransition(
          animation: _controller,
          child: child,
        );
      },
      child: card,
    );

    return Visibility(
      visible: _controller.status != AnimationStatus.dismissed,
      child: animedCard,
    );
  }

  void _updateAnimation() {
    if (_savedPositionNotifier.value != null &&
        !_savedPositionNotifier.value!.near(_positionNotifier.value)) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _hide() {
    _savedPositionNotifier.value = null;
  }
}
