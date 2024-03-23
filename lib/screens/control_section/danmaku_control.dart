import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/danmaku.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DanmakuControl extends StatefulWidget {
  const DanmakuControl({super.key});

  @override
  State<DanmakuControl> createState() => _DanmakuControlState();
}

class _DanmakuControlState extends State<DanmakuControl> {
  late final _danmakuMode = context.read<DanmakuMode>();

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _danmakuMode.value = true;
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      _danmakuMode.value = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
        const SizedBox(width: 8),

        // Text field
        Expanded(
          child: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.space):
                  DoNothingAndStopPropagationTextIntent(),
              SingleActivator(LogicalKeyboardKey.escape):
                  DoNothingAndStopPropagationTextIntent(),
            },
            child: TextField(
              style: const TextStyle(height: 1.0),
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '按回车键发送弹幕',
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              onSubmitted: (value) {
                if (value == '陈子祎') {
                  Actions.invoke(
                    context,
                    const SendMessageIntent('popmoji 1f416'),
                  );
                } else {
                  Actions.invoke(context, SendDanmakuIntent(value));
                }
                _controller.clear();
                _focusNode.requestFocus();
              },
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Popmoji Button
        IconButton(
          icon: const Icon(Icons.mood),
          onPressed: () => Navigator.of(context).pushNamed('control:popmoji'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
