import 'dart:math';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/danmaku/models/data.dart';
import 'package:bunga_player/screens/widgets/text_editing_shortcut_wrapper.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../widgets/popmoji_button.dart';
import 'actions.dart';
import 'panel/popmoji.dart';

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
      StyledWidget(
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            _focusNode.nextFocus();
            Actions.invoke(context, ToggleDanmakuControlIntent(show: false));
          },
        ),
      ).padding(left: 8.0),
      TextEditingShortcutWrapper(
        child: TextField(
          style: const TextStyle(height: 1.0),
          controller: _controller,
          autofocus: kIsDesktop,
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
            hintText: '按换行键发送弹幕',
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          onSubmitted: (value) {
            _sendDanmaku(value);
            _controller.clear();
            if (kIsDesktop) _focusNode.requestFocus();
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
        final popmojis = Consumer<RecentPopmojisNotifier>(
          builder: (context, recentPopmojis, child) {
            return [
              ...recentPopmojis.value
                  .sublist(
                    0,
                    min(recentPopmojis.value.length, maxPopmojisCount),
                  )
                  .map((emoji) {
                    final label = context.read<EmojiData>().tags[emoji]?.first;
                    return Tooltip(
                      margin: const EdgeInsets.all(8),
                      preferBelow: false,
                      decoration: BoxDecoration(
                        color: Colors.grey[700]!.withAlpha(150),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      richMessage: WidgetSpan(
                        child: [
                          Lottie.asset(
                            EmojiData.lottiePath(emoji),
                            repeat: true,
                            height: 64,
                          ),
                          if (label != null)
                            Text(label)
                                .textStyle(
                                  Theme.of(context).textTheme.labelMedium!,
                                )
                                .padding(top: 4.0),
                        ].toColumn().padding(all: 8.0),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: PopmojiButton(
                          emoji,
                          size: buttonSize,
                          onPressed: Actions.handler(
                            context,
                            SendPopmojiIntent(emoji),
                          ),
                        ),
                      ),
                    );
                  }),
              IconButton(
                onPressed: Actions.handler(
                  context,
                  ShowPanelIntent(builder: (context) => const PopmojiPanel()),
                ),
                icon: Icon(Icons.add_circle_outline),
              ),
            ].toRow();
          },
        );

        return [
          danmakuField.flexible(),
          popmojis.padding(horizontal: 8.0),
        ].toRow(mainAxisSize: .max);
      },
    );
  }

  static const _easterEgg = {'陈子祎': '🐖', '张丰年': '🤡'};
  void _sendDanmaku(String message) {
    final easterCode = _easterEgg[message];
    final messageData = easterCode != null
        ? PopmojiMessageData(popmojiCode: easterCode)
        : DanmakuMessageData(message: message);

    Actions.invoke(context, SendMessageIntent(messageData));
  }
}
