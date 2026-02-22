import 'dart:math';

import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/danmaku/models/data.dart';
import 'package:bunga_player/screens/widgets/text_editing_shortcut_wrapper.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widgets/popmoji_button.dart';
import 'panel.dart';

class PopmojiPanel extends StatefulWidget implements Panel {
  @override
  final type = 'popmoji';

  const PopmojiPanel({super.key});

  @override
  State<PopmojiPanel> createState() => _PopmojiPanelState();
}

class _PopmojiPanelState extends State<PopmojiPanel> {
  late final _categories = context.read<EmojiData>().categories;
  late List<EmojiCategory> _data = _categories;

  // Preview overlay
  final _currentHoveredEmoji = ValueNotifier<String?>(null);
  double _overlayY = 0.0;
  late final OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();

    runAfterBuild(() {
      _overlayEntry = OverlayEntry(
        builder: (overlayContext) {
          const size = 180.0;

          return ValueListenableBuilder(
            valueListenable: _currentHoveredEmoji,
            builder: (context, emoji, child) {
              if (emoji == null) return const SizedBox.shrink();
              final appHeight =
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.bottom;

              final label = context.read<EmojiData>().tags[emoji]?.first;
              return [
                    Lottie.asset(EmojiData.lottiePath(emoji), repeat: true),
                    if (label != null)
                      Text(label)
                          .textStyle(Theme.of(context).textTheme.labelLarge!)
                          .padding(top: 8.0),
                  ]
                  .toColumn()
                  .padding(all: 12.0)
                  .card(color: Colors.grey[700]!.withAlpha(150))
                  .positioned(
                    right: _panelWidth - 24.0,
                    top: min(_overlayY, appHeight - size - 36.0),
                    width: size,
                  );
            },
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry);
    });
  }

  @override
  void dispose() {
    _currentHoveredEmoji.dispose();

    _overlayEntry.remove();

    super.dispose();
  }

  double _panelWidth = 0;

  @override
  Widget build(BuildContext context) {
    const buttonSize = 56.0;

    final actions = [
      TextEditingShortcutWrapper(
        child: TextField(
          autofocus: kIsDesktop,
          decoration: const InputDecoration(
            hintText: '搜索表情',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(36)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _data = _categories;
              });
              return;
            }

            setState(() {
              _data = _emojisByTag(value);
            });
          },
        ),
      ).padding(left: 8.0).flexible(),
    ];

    return Consumer<SplitPlacement>(
      builder: (context, placement, child) {
        _panelWidth = placement.size;
        final lineCount = _panelWidth ~/ buttonSize;
        var items = _sliceItems(_data, lineCount);
        if (items.isEmpty) items = ['无结果'];

        return PanelWidget(
          actions: actions,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24, left: 8.0, right: 8.0),
            itemCount: items.length,
            prototypeItem: const SizedBox(height: buttonSize),
            itemBuilder: (context, index) {
              if (items[index] is String) {
                return [
                  const Spacer(),
                  Text(
                    items[index],
                  ).textStyle(Theme.of(context).textTheme.labelLarge!),
                  const Divider(),
                ].toColumn().alignment(.bottomCenter).padding(horizontal: 8.0);
              }

              final emojiRow = (items[index] as List)
                  .map(
                    (emoji) => Builder(
                      builder: (context) {
                        return PopmojiButton(
                          emoji,
                          size: buttonSize,
                          onPressed: () {
                            Actions.invoke(context, SendPopmojiIntent(emoji));
                            _addToRecent(emoji);
                          },
                          onHover: (isHovered) {
                            if (!isHovered) {
                              _currentHoveredEmoji.value = null;
                              return;
                            }

                            final renderbox =
                                context.findRenderObject() as RenderBox?;
                            final y = renderbox!.localToGlobal(Offset.zero).dy;

                            _overlayY = y;
                            _currentHoveredEmoji.value = emoji;
                          },
                        );
                      },
                    ),
                  )
                  .toList()
                  .toRow(mainAxisAlignment: MainAxisAlignment.center);

              return RepaintBoundary(child: emojiRow);
            },
          ).overflow(minWidth: placement.size, alignment: .topLeft),
        );
      },
    );
  }

  void _addToRecent(String emoji) {
    final notifier = context.read<RecentPopmojisNotifier>();
    final emojis = notifier.value;
    emojis
      ..remove(emoji)
      ..insert(0, emoji);
    notifier.value = [...emojis];
  }

  List _sliceItems(List<EmojiCategory> categories, int count) {
    final items = [];

    for (var category in categories) {
      items.add(category.name);

      var remain = category.emojis;
      while (remain.length > count) {
        items.add(remain.sublist(0, count));
        remain = remain.sublist(count);
      }
      if (remain.isNotEmpty) items.add(remain);
    }

    return items;
  }

  List<EmojiCategory> _emojisByTag(String keyword) {
    final data = context.read<EmojiData>();

    final result = <EmojiCategory>[];
    for (var category in data.categories) {
      final emojis = category.emojis.where(
        (emoji) => _tagsContainKeyword(data.tags[emoji]!, keyword),
      );
      if (emojis.isNotEmpty) {
        result.add(EmojiCategory(name: category.name, emojis: emojis.toList()));
      }
    }

    return result;
  }

  bool _tagsContainKeyword(List<String> tags, String keyword) {
    for (var tag in tags) {
      if (tag.contains(keyword)) return true;
    }
    return false;
  }
}
