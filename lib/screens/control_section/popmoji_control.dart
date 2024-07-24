import 'dart:ui';

import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/popmoji/models/data.dart';
import 'package:bunga_player/popmoji/models/message_data.dart';
import 'package:bunga_player/popmoji/providers.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bunga_player/mocks/tooltip.dart' as mock;
import 'package:lottie/lottie.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../widgets/divider.dart';

class PopmojiControl extends StatefulWidget {
  const PopmojiControl({super.key});

  @override
  State<PopmojiControl> createState() => _PopmojiControlState();
}

class _PopmojiControlState extends State<PopmojiControl> {
  final _buttonSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxButtons = constraints.maxWidth ~/ _buttonSize - 3;

      return Consumer<PopmojiBarItems>(
        builder: (context, emojisNotifier, child) {
          late final List<String> pinned, recent;
          if (emojisNotifier.value.pinned.length > maxButtons) {
            pinned = emojisNotifier.value.pinned.sublist(0, maxButtons);
            recent = [];
          } else {
            pinned = emojisNotifier.value.pinned;

            final remainCount = maxButtons - pinned.length;
            final allRecent = emojisNotifier.value.recent;
            recent = allRecent.length <= remainCount
                ? allRecent
                : allRecent.sublist(0, remainCount);
          }

          return ReorderableListView(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            onReorder: (int oldIndex, int newIndex) {
              EmojiIndex toEmojiIndex(int index) {
                if (index <= pinned.length) {
                  return (
                    list: EmojiListType.pinned,
                    index: index,
                  );
                } else {
                  return (
                    list: EmojiListType.recent,
                    index: index - pinned.length - 1,
                  );
                }
              }

              emojisNotifier.move(
                toEmojiIndex(oldIndex),
                toEmojiIndex(newIndex),
              );
            },
            header: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
            ),
            footer: Center(
              child: IconButton(
                onPressed: _showAllEmojis,
                icon: const Icon(Icons.more_horiz),
              ),
            ),
            children: [
              ...pinned.asMap().entries.map(
                    (entry) => _DragWrapper(
                      index: entry.key,
                      child: _EmojiButton(
                        entry.value,
                        onPressed: () => _sendEmoji(entry.value),
                        size: _buttonSize,
                      ),
                    ),
                  ),
              if (recent.isNotEmpty)
                const ControlDivider(key: ValueKey('barDivicer')),
              ...recent.asMap().entries.map((entry) => _DragWrapper(
                    index: entry.key + pinned.length + 1,
                    child: _EmojiButton(
                      entry.value,
                      onPressed: () => _sendEmoji(entry.value),
                      size: _buttonSize,
                    ),
                  )),
            ],
          );
        },
      );
    });
  }

  void _showAllEmojis() async {
    final barItems = context.read<PopmojiBarItems>();

    final selected = await showModalBottomSheet<String?>(
      context: context,
      useRootNavigator: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) => const _EmojiSheet(),
    );
    if (selected == null) return;

    _sendEmoji(selected);

    barItems.addRecent(selected);
  }

  void _sendEmoji(String emoji) {
    // send popmoji
    Actions.invoke(
      context,
      SendMessageIntent(PopmojiMessageData(
        code: EmojiData.codePoint(emoji),
      ).toMessageData()),
    );
  }
}

class _DragWrapper extends SingleChildStatelessWidget {
  final int index;

  _DragWrapper({required this.index, super.child})
      : super(key: ValueKey(index));

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ReorderableDragStartListener(
      index: index,
      child: Center(child: child),
    );
  }
}

class _EmojiSheet extends StatefulWidget {
  static const emojiSize = 52.0;

  const _EmojiSheet();

  @override
  State<_EmojiSheet> createState() => _EmojiSheetState();
}

class _EmojiSheetState extends State<_EmojiSheet> {
  late final _categories = context.read<EmojiData>().categories;
  late List<EmojiCategory> _data = _categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        scrolledUnderElevation: 11,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 24),
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
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close),
            ),
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        var items = _sliceItems(
          _data,
          (constraints.maxWidth - 48) ~/ _EmojiSheet.emojiSize,
        );
        if (items.isEmpty) items = ['无结果'];

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          itemCount: items.length,
          prototypeItem: const SizedBox(height: _EmojiSheet.emojiSize),
          itemBuilder: (context, index) => items[index] is String
              ? Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Text(items[index]),
                )
              : Row(
                  children: items[index]
                      .map<Widget>(
                        (emoji) => _EmojiButton(
                          emoji,
                          waitDuration: const Duration(milliseconds: 500),
                          onPressed: () => Navigator.of(context).pop(emoji),
                          size: _EmojiSheet.emojiSize,
                        ),
                      )
                      .toList(),
                ),
        );
      }),
    );
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
        result.add(EmojiCategory(
          name: category.name,
          emojis: emojis.toList(),
        ));
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

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final double size;
  final VoidCallback onPressed;
  final Duration? waitDuration;

  const _EmojiButton(
    this.emoji, {
    this.size = 40,
    this.waitDuration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size - 16;
    final svg = SvgPicture(
      AssetBytesLoader(EmojiData.svgPath(emoji)),
      width: iconSize,
      height: iconSize,
    );

    final button = IconButton(
      icon: svg,
      onPressed: () {
        _showThrowEmojiAnimation(context);
        onPressed();
      },
    );

    return mock.Tooltip(
      waitDuration: waitDuration,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor.withOpacity(0.85),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      richMessage: WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Lottie.asset(
                EmojiData.lottiePath(emoji),
                repeat: true,
                height: 64,
              ),
              const SizedBox(height: 4),
              Text(context.read<EmojiData>().tags[emoji]?.first ?? ''),
            ],
          ),
        ),
      ),
      rootOverlay: true,
      child: button,
    );
  }

  void _showThrowEmojiAnimation(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(
      context,
      rootNavigator: true,
    ).overlay!.context.findRenderObject()! as RenderBox;
    final position = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero),
          ancestor: overlay),
    );

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ThrowAnimation(
          startRect: position,
          endRect: Rect.fromLTWH(
            overlay.size.width / 2,
            overlay.size.height / 2,
            0,
            0,
          ),
          overlay: overlayEntry,
          child: SvgPicture.asset(EmojiData.svgPath(emoji)),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }
}

class _ThrowAnimation extends SingleChildStatefulWidget {
  final Rect startRect, endRect;
  final OverlayEntry overlay;
  const _ThrowAnimation({
    required this.startRect,
    required this.endRect,
    required this.overlay,
    super.child,
  });
  @override
  State<_ThrowAnimation> createState() => _ThrowAnimationState();
}

class _ThrowAnimationState extends SingleChildState<_ThrowAnimation>
    with SingleTickerProviderStateMixin {
  late final _path = Path()
    ..moveTo(widget.startRect.left, widget.startRect.top)
    ..quadraticBezierTo(
      widget.startRect.left,
      widget.endRect.top,
      widget.endRect.left,
      widget.endRect.top,
    );
  late var _position = Offset(
    widget.startRect.left,
    widget.startRect.top,
  );
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));
  late final _positionTween = Tween(begin: 0.0, end: 1.0)
      .chain(CurveTween(curve: Curves.easeOutCubic))
      .animate(_controller);
  late final _sizeTween = TweenSequence<double>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween(begin: 0, end: -1),
      ),
      TweenSequenceItem(
        weight: 1.6,
        tween: Tween(begin: -1, end: 1),
      ),
    ],
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);

  @override
  void initState() {
    super.initState();

    _positionTween.addListener(() {
      setState(() {
        _calcPosition(_positionTween.value);
      });
    });
    _controller.forward().then((_) => widget.overlay.remove());
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final rect = Rect.lerp(widget.startRect, widget.endRect, _sizeTween.value)!;
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          width: rect.width,
          height: rect.height,
          child: child!,
        ),
      ],
    );
  }

  void _calcPosition(double tween) {
    PathMetrics pathMetrics = _path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    tween = pathMetric.length * tween;
    _position = pathMetric.getTangentForOffset(tween)!.position;
  }
}
