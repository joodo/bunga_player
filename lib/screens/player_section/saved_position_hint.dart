import 'package:animations/animations.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/screens/wrappers/theme.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  late final _savedPositionNotifier = context.read<PlaySavedPosition>();
  late final _positionNotifier = context.read<PlayPosition>();

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
    final savedPosition =
        context.read<PlaySavedPosition>().value ?? Duration.zero;
    final card = Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('上回看到 ${savedPosition.hhmmss}'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Actions.maybeInvoke(context, SeekIntent(savedPosition));
              _hide();
            },
            child: const Text('跳转'),
          ),
          IconButton(
            onPressed: _hide,
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );

    final themedCard = Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeWrapper.seedColor),
      ),
      child: card,
    );

    final animedCard = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return FadeScaleTransition(
          animation: _controller,
          child: child,
        );
      },
      child: themedCard,
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
    context.read<PlaySavedPosition>().value = null;
  }
}
