import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class RenameControl extends StatefulWidget {
  final String? previousName;
  const RenameControl({super.key, required this.previousName});

  @override
  State<RenameControl> createState() => _RenameControlState();
}

class _RenameControlState extends State<RenameControl> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Auto login
    Future.delayed(Duration.zero, () {
      final savedUserName = Preferences().get<String>('user_name');
      if (savedUserName != null) {
        _onSubmit(savedUserName);
      } else {
        UINotifiers().hintText.value = '怎样称呼你？';
      }
    });

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

  void _onSubmit(String userName) async {
    Chat().renameUser(userName).onError((error, stackTrace) {
      logger.e(error);
      showSnackBar('改名失败');
    });

    Preferences().set('user_name', userName);
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
