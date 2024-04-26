import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RenameControl extends StatefulWidget {
  const RenameControl({super.key});

  @override
  State<RenameControl> createState() => _RenameControlState();
}

class _RenameControlState extends State<RenameControl> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CatIndicator>().title = '怎样称呼你？';

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final name = args?['name'];
      _textController.text = name ?? '';
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: DefaultTextEditingShortcuts(
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
    context.read<SettingUserName>().value = userName;
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
