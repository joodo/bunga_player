import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widgets/popmoji_button.dart';
import '../actions.dart';
import '../panel/popmoji.dart';
import 'business.dart';

class DanmakuControl extends StatefulWidget {
  const DanmakuControl({super.key});

  @override
  State<DanmakuControl> createState() => _DanmakuControlState();
}

class _DanmakuControlState extends State<DanmakuControl> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danmakuField = [
      StyledWidget(IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: Actions.handler(
          context,
          ToggleDanmakuControlIntent(show: false),
        ),
      )).padding(left: 8.0),
      DefaultTextEditingShortcuts(
        child: TextField(
          style: const TextStyle(height: 1.0),
          controller: _controller,
          autofocus: true,
          focusNode: _focusNode,
          onTapOutside: (event) {},
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2.0,
              ),
            ),
            hintText: '按回车键发送弹幕',
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          onSubmitted: (value) {
            _controller.clear();
            _focusNode.requestFocus();
          },
        ),
      ).padding(left: 8.0).flexible(),
    ].toRow();

    const buttonSize = 40.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxPopmojisWidth = constraints.maxWidth - 500.0;
        int maxPopmojisCount = maxPopmojisWidth ~/ buttonSize - 1;
        maxPopmojisCount = max(maxPopmojisCount, 1);
        final popmojis = Consumer<ValueNotifier<List<String>>>(
          builder: (context, recentPopmojis, child) {
            return [
              ...recentPopmojis.value
                  .sublist(
                      0, min(recentPopmojis.value.length, maxPopmojisCount))
                  .map((emoji) => PopmojiButton(
                        emoji,
                        size: buttonSize,
                        onPressed: () {},
                      )),
              IconButton(
                onPressed: Actions.handler(
                  context,
                  ShowPanelIntent(builder: (context) => const PopmojiPanel()),
                ),
                icon: Icon(Icons.more_horiz),
              ),
            ].toRow();
          },
        );

        return [
          danmakuField.flexible(),
          popmojis.padding(horizontal: 8.0),
        ].toRow(mainAxisSize: MainAxisSize.max).wrapDanmakuBusiness();
      },
    );
  }
}
