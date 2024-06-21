import 'package:animations/animations.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'theme.dart';

class ToastWrapper extends SingleChildStatefulWidget {
  const ToastWrapper({super.key, super.child});

  @override
  State<ToastWrapper> createState() => ToastWrapperState();
}

class ToastWrapperState extends SingleChildState<ToastWrapper>
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
    const Duration(milliseconds: 1500),
  );
  late final _textNotifer = ValueNotifier<String?>(null);

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
    _textNotifer.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final card = Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: ValueListenableBuilder(
        valueListenable: _textNotifer,
        builder: (context, text, child) => text != null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(text),
              )
            : const SizedBox.shrink(),
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

    final body = Stack(
      alignment: Alignment.centerLeft,
      children: [
        if (child != null) child,
        Positioned(
          bottom: 72,
          left: 12,
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
    _textNotifer.value = text;
    _visibleNotifier.mark();
  }
}
