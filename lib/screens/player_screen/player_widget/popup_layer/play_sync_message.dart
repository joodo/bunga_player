import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

class PlaySyncMessage extends StatefulWidget {
  const PlaySyncMessage({super.key});

  @override
  State<PlaySyncMessage> createState() => _PlaySyncMessageState();
}

class _PlaySyncMessageState extends State<PlaySyncMessage> {
  final _visibleNotifier = AutoResetNotifier(const Duration(seconds: 3));
  final _messageNotifier = ValueNotifier<String>('');

  late final StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context.read<PlaySyncMessageManager>().messageStream.listen(
      _onNewMessage,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _visibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snackBarTheme = Theme.of(context).snackBarTheme;
    return ValueListenableBuilder(
      valueListenable: _visibleNotifier,
      builder: (context, visible, child) => PopupWidget(
        showing: visible,
        layoutBuilder: (context, child) =>
            child.alignment(.bottomLeft).padding(left: 20.0, bottom: 80.0),
        child: child!,
      ),
      child:
          ValueListenableBuilder<String>(
                valueListenable: _messageNotifier,
                builder: (context, message, child) =>
                    Text(message, style: snackBarTheme.contentTextStyle),
              )
              .padding(all: 16.0)
              .card(
                shape: snackBarTheme.shape,
                elevation: snackBarTheme.elevation,
              )
              .theme(data: ThemeData()),
    );
  }

  void _onNewMessage(String message) {
    _visibleNotifier.mark();
    _messageNotifier.value = message;
  }
}
