import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/danmaku/models/emoji_data.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';

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
              final preview =
                  [
                        Lottie.asset(EmojiData.lottiePath(emoji), repeat: true),
                        if (label != null)
                          Text(label)
                              .textStyle(
                                Theme.of(context).textTheme.labelLarge!,
                              )
                              .padding(top: 8.0),
                      ]
                      .toColumn()
                      .padding(all: 12.0)
                      .card(color: Colors.grey[700]!.withAlpha(150));
              return preview.positioned(
                right: _panelWidth,
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

    final title = TextEditingShortcutWrapper(
      child: TextField(
        autofocus: kIsDesktop,
        decoration: const InputDecoration(hintText: '搜索表情'),
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
    );

    Widget categoryBuilder(EmojiCategory category) {
      Widget emojiBuilder(BuildContext context, int index) {
        return Builder(
          builder: (context) {
            final emoji = category.emojis[index];
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

                final renderbox = context.findRenderObject() as RenderBox?;
                final y = renderbox!.localToGlobal(Offset.zero).dy;

                _overlayY = y;
                _currentHoveredEmoji.value = emoji;
              },
            );
          },
        );
      }

      final categoryLabel = SliverAppBar(
        title: Text(
          category.name,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white54),
        ),
        toolbarHeight: 36.0,
        pinned: true,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      );

      return SliverMainAxisGroup(
        slivers: [
          categoryLabel,
          SliverRepaintBoundary(
            child: SliverGrid.builder(
              itemCount: category.emojis.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64.0,
                mainAxisExtent: 64.0,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemBuilder: emojiBuilder,
            ),
          ),
        ],
      );
    }

    final body = CustomScrollView(
      controller: PrimaryScrollController.of(context),
      slivers: [
        SliverMainAxisGroup(slivers: _data.map(categoryBuilder).toList()),
      ],
    );

    return Consumer<SplitPlacement>(
      builder: (context, placement, child) {
        _panelWidth = placement.size;

        return PanelWidget(
          title: title,
          child: child!
              .constrained(width: _panelWidth)
              .overflow(maxWidth: _panelWidth, minWidth: _panelWidth)
              .clipRect(),
        );
      },
      child: body,
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

class SliverRepaintBoundary extends SingleChildRenderObjectWidget {
  const SliverRepaintBoundary({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverRepaintBoundary();
  }
}

class RenderSliverRepaintBoundary extends RenderProxySliver {
  @override
  bool get isRepaintBoundary => true;
}
