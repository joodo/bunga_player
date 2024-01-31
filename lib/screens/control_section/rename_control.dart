import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/logger.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BusinessName>().value = '怎样称呼你？';
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
    context.read<CurrentUser>().rename(userName).onError((error, stackTrace) {
      logger.e(error);
      context.showToast('改名失败');
      throw error ?? '改名失败';
    });
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
