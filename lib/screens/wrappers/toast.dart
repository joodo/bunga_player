import 'package:animations/animations.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

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

  final _bottomOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    _service.register(show);
    _service.registerOffsetNotifier(_bottomOffset);

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
    _service.unregisterOffsetNotifier(_bottomOffset);
    _visibleNotifier.dispose();
    _textNotifer.dispose();
    _bottomOffset.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final card = ValueListenableBuilder(
      valueListenable: _textNotifer,
      builder: (context, text, child) => text != null
          ? Text(text).padding(horizontal: 16.0, vertical: 12.0)
          : const SizedBox.shrink(),
    ).card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
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
      builder: (BuildContext context, Widget? child) => FadeScaleTransition(
        animation: _controller,
        child: child,
      ),
      child: themedCard,
    );

    final body = ValueListenableBuilder(
      valueListenable: _bottomOffset,
      builder: (context, value, child) {
        return [
          if (child != null) child,
          Visibility(
            visible: _controller.status != AnimationStatus.dismissed,
            child: animedCard,
          ).positioned(bottom: 72.0 + _bottomOffset.value, left: 12.0),
        ].toStack(alignment: Alignment.centerLeft);
      },
      child: child,
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
