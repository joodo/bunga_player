import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
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

    _textController.text = getIt<Preferences>().get<String>('user_name') ?? '';
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CatIndicator>().title = '怎样称呼你？';
    });
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
    getIt<Preferences>().set('user_name', userName);
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
