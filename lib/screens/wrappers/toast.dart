import 'package:animations/animations.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class ToastWrapper extends SingleChildStatefulWidget {
  const ToastWrapper({super.key, super.child});

  @override
  State<ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends SingleChildState<ToastWrapper>
    with SingleTickerProviderStateMixin {
  late final _service = getIt<Toast>();

  late final _controller = AnimationController(
    value: 0.0,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 75),
    vsync: this,
  )..addStatusListener((AnimationStatus status) {
      setState(() {});
    });

  late final _visibleNotifier = AutoResetNotifier(
    const Duration(milliseconds: 3000),
  );
  late final _textNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    _service.register(show);

    _visibleNotifier.addListener(() {
      if (_visibleNotifier.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _service.unregister(show);
    _visibleNotifier.dispose();
    _textNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final card = Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ValueListenableBuilder(
          valueListenable: _textNotifier,
          builder: (context, value, child) => Text(value),
        ),
      ),
    );

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

    final body = Stack(
      alignment: Alignment.center,
      children: [
        if (child != null) child,
        Positioned(
          bottom: 80,
          child: Visibility(
            visible: _controller.status != AnimationStatus.dismissed,
            child: animedCard,
          ),
        ),
      ],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: body,
    );
  }

  void show(String text) {
    _textNotifier.value = text;
    _visibleNotifier.mark();
  }
}
