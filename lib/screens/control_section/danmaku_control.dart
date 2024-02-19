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
  final _controller = TextEditingController();

  late final _danmakuMode = context.read<DanmakuMode>();
  // late final _showDanmakuHistory = context.read<ShowDanmakuHistory>();

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
      // _showDanmakuHistory.value = false;
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
                Actions.invoke(context, SendDanmakuIntent(value));
                _controller.clear();
                _focusNode.requestFocus();
              },
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Popmoji Button
        // FIXME: popmoji finish will cause textField lose focus, see
        // https://github.com/flutter/flutter/issues/112367
        IconButton(
          icon: const Icon(Icons.mood),
          onPressed: () => Navigator.of(context).pushNamed('control:popmoji'),
        ),
        const SizedBox(width: 8),

        // TODO: History button
        /*
        ValueListenableBuilder(
          valueListenable: _showDanmakuHistory,
          builder: (context, showHistory, child) => IconButton(
            icon: const Icon(Icons.history),
            isSelected: showHistory,
            onPressed: () => _showDanmakuHistory.value = !showHistory,
          ),
        ),
        const SizedBox(width: 8),
        */
      ],
    );
  }
}
