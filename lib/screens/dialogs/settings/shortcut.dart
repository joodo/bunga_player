import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class ShortcutSettings extends StatefulWidget with SettingsTab {
  @override
  final label = '快捷键';
  @override
  final icon = Icons.keyboard_outlined;
  @override
  final selectedIcon = Icons.keyboard;

  const ShortcutSettings({super.key});

  @override
  State<ShortcutSettings> createState() => _ShortcutSettingsState();
}

class _ShortcutSettingsState extends State<ShortcutSettings> {
  static const Map<String, Map<String, ShortcutKey>> _categories = {
    '播放': {
      '增加音量': ShortcutKey.volumeUp,
      '减少音量': ShortcutKey.volumeDown,
      '快进 5 秒': ShortcutKey.forward5Sec,
      '后退 5 秒': ShortcutKey.backward5Sec,
      '播放 / 暂停': ShortcutKey.togglePlay,
      '截图': ShortcutKey.screenshot,
    },
    '互动': {
      '弹幕聊天': ShortcutKey.danmaku,
    },
    '语音': {
      '增加语音音量': ShortcutKey.voiceVolumeUp,
      '减少语音音量': ShortcutKey.voiceVolumeDown,
      '闭麦': ShortcutKey.muteMic,
    },
  };

  late final ShortcutMappingNotifier _shortcutMapNotifier =
      context.read<ShortcutMappingNotifier>();
  late Map<ShortcutKey, SingleActivator?> _shortcutMap =
      Map.from(_shortcutMapNotifier.value);

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _shortcutMapNotifier.value = Map.unmodifiable(_shortcutMap);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return [
      ..._categories.entries
          .map((category) => [
                Text(category.key).sectionTitle(),
                category.value.entries
                    .map(
                      (shortcut) => _ShortcutListTile(
                        title: shortcut.key,
                        conflict: _shortcutMap.values
                                .where((element) =>
                                    element?.serialize() ==
                                    _shortcutMap[shortcut.value]?.serialize())
                                .length >
                            1,
                        value: _shortcutMap[shortcut.value],
                        onChanged: (newShortcut) {
                          setState(() {
                            _shortcutMap[shortcut.value] = newShortcut;
                          });
                        },
                      ),
                    )
                    .toList()
                    .toColumn(separator: const Divider(height: 0))
                    .sectionContainer(),
              ])
          .expand((list) => list),
      OutlinedButton(
        onPressed: () => setState(() {
          _shortcutMap = Map.from(ShortcutMappingNotifier.defaultMapping);
        }),
        child: const Text('恢复默认键位'),
      ).padding(top: 24.0).center(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }
}

class _ShortcutListTile extends StatelessWidget {
  final String title;
  final SingleActivator? value;
  final bool conflict;
  final ValueSetter<SingleActivator?>? onChanged;

  const _ShortcutListTile({
    required this.title,
    this.value,
    this.onChanged,
    this.conflict = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: conflict
          ? Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.error,
            )
          : null,
      trailing: _ShortcutViewer(
        shortcut: value,
        placeholder: const Text('无'),
      ),
      splashColor: Colors.transparent,
      onTap: () async {
        final box = context.findRenderObject()! as RenderBox;
        final topLeft = box.localToGlobal(Offset.zero);
        final bottomRight = box.localToGlobal(box.paintBounds.bottomRight);

        final result = await _showDialog(
          context,
          Rect.fromPoints(topLeft, bottomRight),
        );
        if (result != null) {
          onChanged?.call(result.trigger.keyId != 0 ? result : null);
        }
      },
    );
  }

  Future<SingleActivator?> _showDialog(BuildContext context, Rect rect) {
    return showDialog<SingleActivator?>(
      context: context,
      builder: (context) {
        final safePadding = MediaQuery.of(context).viewInsets;
        final offset = rect.topLeft - safePadding.topLeft;
        return Dialog(
          alignment: Alignment.topLeft,
          insetPadding: EdgeInsets.only(left: offset.dx, top: offset.dy),
          child: ListTile(
            title: Text(title),
            trailing: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(const SingleActivator(LogicalKeyboardKey(0))),
                child: const Text('清空'),
              ),
              const SizedBox(width: 8),
              _ShortcutRecorder(
                placeholder: const Text('输入新快捷键'),
                onFinished: (value) => Navigator.of(context).pop(value),
              ),
            ].toRow(mainAxisSize: MainAxisSize.min),
          ).constrained(width: rect.width, height: rect.height),
        );
      },
    );
  }
}

class _ShortcutViewer extends StatelessWidget {
  final SingleActivator? shortcut;
  final Widget? placeholder;

  const _ShortcutViewer({this.shortcut, this.placeholder});

  @override
  Widget build(BuildContext context) {
    if (shortcut == null) return placeholder ?? const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: [
        if (shortcut!.meta) const _VirtualKeyView(LogicalKeyboardKey.meta),
        if (shortcut!.control)
          const _VirtualKeyView(LogicalKeyboardKey.control),
        if (shortcut!.alt) const _VirtualKeyView(LogicalKeyboardKey.alt),
        if (shortcut!.shift) const _VirtualKeyView(LogicalKeyboardKey.shift),
        if (shortcut!.trigger.keyId != 0) _VirtualKeyView(shortcut!.trigger),
      ],
    );
  }
}

class _VirtualKeyView extends StatelessWidget {
  static final _alternateLabel = {
    LogicalKeyboardKey.space: '␣',
    LogicalKeyboardKey.arrowUp: '↑',
    LogicalKeyboardKey.arrowDown: '↓',
    LogicalKeyboardKey.arrowLeft: '←',
    LogicalKeyboardKey.arrowRight: '→',
  };

  const _VirtualKeyView(this.logicalKey);

  final LogicalKeyboardKey logicalKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      child: Text(_alternateLabel[logicalKey] ?? logicalKey.keyLabel)
          .fontSize(12.0)
          .textColor(theme.textTheme.bodyMedium!.color)
          .padding(horizontal: 5.0, vertical: 3.0)
          .decorated(
        color: theme.canvasColor,
        border: Border.all(color: theme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
    );
  }
}

class _ShortcutRecorder extends StatefulWidget {
  final Widget? placeholder;
  final ValueSetter<SingleActivator>? onFinished;

  const _ShortcutRecorder({this.placeholder, this.onFinished});

  @override
  State<_ShortcutRecorder> createState() => _ShortcutRecorderState();
}

class _ShortcutRecorderState extends State<_ShortcutRecorder> {
  LogicalKeyboardKey? _trigger;
  int _meta = 0, _control = 0, _alt = 0, _shift = 0;
  SingleActivator get _shortcut => SingleActivator(
        _trigger ?? const LogicalKeyboardKey(0),
        meta: _meta > 0,
        control: _control > 0,
        alt: _alt > 0,
        shift: _shift > 0,
      );

  bool _freeze = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if ([
            LogicalKeyboardKey.metaLeft,
            LogicalKeyboardKey.metaRight,
          ].contains(event.logicalKey)) {
            _meta++;
          } else if ([
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.controlRight,
          ].contains(event.logicalKey)) {
            _control++;
          } else if ([
            LogicalKeyboardKey.altLeft,
            LogicalKeyboardKey.altRight,
          ].contains(event.logicalKey)) {
            _alt++;
          } else if ([
            LogicalKeyboardKey.shiftLeft,
            LogicalKeyboardKey.shiftRight,
          ].contains(event.logicalKey)) {
            _shift++;
          } else {
            _trigger = event.logicalKey;
          }
        } else {
          if (_trigger == null) {
            if ([
              LogicalKeyboardKey.metaLeft,
              LogicalKeyboardKey.metaRight,
            ].contains(event.logicalKey)) {
              _meta--;
            } else if ([
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.controlRight,
            ].contains(event.logicalKey)) {
              _control--;
            } else if ([
              LogicalKeyboardKey.altLeft,
              LogicalKeyboardKey.altRight,
            ].contains(event.logicalKey)) {
              _alt--;
            } else if ([
              LogicalKeyboardKey.shiftLeft,
              LogicalKeyboardKey.shiftRight,
            ].contains(event.logicalKey)) {
              _shift--;
            }
          } else if (_trigger == event.logicalKey) {
            widget.onFinished?.call(_shortcut);
            _freeze = true;
          }
        }

        if (!_freeze) setState(() {});

        return KeyEventResult.handled;
      },
      child: _ShortcutViewer(
        shortcut: HardwareKeyboard.instance.physicalKeysPressed.isEmpty
            ? null
            : _shortcut,
        placeholder: widget.placeholder,
      ),
    );
  }
}
