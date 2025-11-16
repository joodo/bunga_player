import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/ui/theme.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

class ToastWrapper extends SingleChildStatefulWidget {
  const ToastWrapper({super.key, super.child});

  @override
  State<ToastWrapper> createState() => ToastWrapperState();
}

class ToastWrapperState extends SingleChildState<ToastWrapper>
    with SingleTickerProviderStateMixin {
  late final _service = getIt<Toast>();

  late final _visibleNotifier = AutoResetNotifier(
    const Duration(milliseconds: 1500),
  );
  late final _textNotifer = ValueNotifier<String?>(null);

  final _bottomOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();

    _service.register(show);
    _service.registerOffsetNotifier(_bottomOffset);
  }

  @override
  void dispose() {
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
    )
        .card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(2.0),
            ),
          ),
        )
        .theme(data: lightTheme);

    final popup = PopupWidget(
      visibleNotifier: _visibleNotifier,
      child: card,
    );

    final body = ValueListenableBuilder(
      valueListenable: _bottomOffset,
      builder: (context, value, child) {
        return [
          if (child != null) child,
          popup.positioned(bottom: 72.0 + _bottomOffset.value, left: 12.0),
        ].toStack(alignment: Alignment.centerLeft);
      },
      child: child,
    );

    return body;
  }

  void show(String text) {
    _textNotifer.value = text;
    _visibleNotifier.mark();
  }
}
