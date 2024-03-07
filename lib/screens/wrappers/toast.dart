import 'package:animations/animations.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/material.dart';

class ToastWrapper extends StatefulWidget {
  const ToastWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<ToastWrapper>
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
  Widget build(BuildContext context) {
    final card = Theme(
      data: ThemeData.light(),
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ValueListenableBuilder(
            valueListenable: _textNotifier,
            builder: (context, value, child) => Text(value),
          ),
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

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned(
          bottom: 80,
          child: Visibility(
            visible: _controller.status != AnimationStatus.dismissed,
            child: animedCard,
          ),
        ),
      ],
    );
  }

  void show(String text) {
    _textNotifier.value = text;
    _visibleNotifier.mark();
  }
}
