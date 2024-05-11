import 'package:animations/animations.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'theme.dart';

class ToastWrapper extends SingleChildStatefulWidget {
  const ToastWrapper({super.key, super.child});

  static ToastWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<ToastWrapperState>()!;
  }

  @override
  State<ToastWrapper> createState() => ToastWrapperState();
}

typedef ToastPayload = ({
  String text,
  Widget? action,
  bool withCloseButton,
});

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
  late final _payloadNotifier = ValueNotifier<ToastPayload?>(null);

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
    _payloadNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final card = Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: ValueListenableBuilder(
        valueListenable: _payloadNotifier,
        builder: (context, payload, child) => payload != null
            ? Row(
                children: [
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(payload.text),
                  ),
                  const SizedBox(width: 8),
                  if (payload.action != null) payload.action!,
                  if (payload.withCloseButton)
                    IconButton(
                      onPressed: hide,
                      icon: const Icon(Icons.close),
                    ),
                  const SizedBox(width: 8),
                ],
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

  void show(
    String text, {
    Widget? action,
    bool withCloseButton = false,
    bool behold = false,
  }) {
    if (_visibleNotifier.locked) return;

    _payloadNotifier.value = (
      text: text,
      action: action,
      withCloseButton: withCloseButton,
    );

    if (!behold) {
      _visibleNotifier.unlock('behold');
      _visibleNotifier.mark();
    } else {
      _visibleNotifier.mark();
      _visibleNotifier.lock('behold');
    }
  }

  void hide() {
    _visibleNotifier.unlock('behold');
    _visibleNotifier.reset();
  }
}
