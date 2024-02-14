import 'dart:async';

import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RenameControl extends StatefulWidget {
  final String? previousName;
  const RenameControl({super.key, required this.previousName});

  @override
  State<RenameControl> createState() => _RenameControlState();
}

class _RenameControlState extends State<RenameControl> {
  final _textController = TextEditingController();

  Completer<void>? _completer;
  void _initBusinessIndicator() {
    final bi = context.read<BusinessIndicator>();
    bi.run(
      tasks: [
        bi.setTitle('怎样称呼你？'),
        (data) {
          _completer = Completer();
          return _completer!.future;
        },
      ],
      showProgress: false,
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(_initBusinessIndicator);

    if (widget.previousName != null) {
      _textController.text = widget.previousName!;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            style: const TextStyle(height: 1.0),
            autofocus: true,
            controller: _textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _onSubmit(value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        ValueListenableBuilder(
          valueListenable: _textController,
          builder: (context, value, child) {
            return FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed:
                  value.text.isNotEmpty ? () => _onSubmit(value.text) : null,
              child: const Text('就这么定'),
            );
          },
        ),
      ],
    );
  }

  void _onSubmit(String userName) {
    Actions.maybeInvoke(context, RenameCurrentUserIntent(userName));

    _completer?.complete();
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
