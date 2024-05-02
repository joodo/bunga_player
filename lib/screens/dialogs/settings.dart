import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/bunga_server/providers.dart';
import 'package:bunga_player/network/providers.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/iterable.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nested/nested.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) => setState(() {
                _selectedIndex = value;
              }),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.lan_outlined),
                  selectedIcon: Icon(Icons.lan),
                  label: Text('网络'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_outlined),
                  selectedIcon: Icon(Icons.chat),
                  label: Text('互动'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.keyboard_outlined),
                  selectedIcon: Icon(Icons.keyboard),
                  label: Text('快捷键'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: Text('关于'),
                ),
              ],
            ),
            Expanded(
              child: LazyIndexedStack(
                index: _selectedIndex,
                sizing: StackFit.expand,
                children: const [
                  _NetworkSettings(),
                  _ReactionSettings(),
                  _ShortcutSettings(),
                  _AboutSetting(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: Navigator.of(context).pop,
      child: const Text('确定'),
    );
  }
}

class _SettingStack extends StatelessWidget {
  final List<Widget>? actions;
  final Widget content;
  const _SettingStack({this.actions, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: 480,
            child: content,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions ?? [const _ConfirmButton()],
          ),
        ),
      ],
    );
  }
}

class _NetworkSettings extends StatefulWidget {
  const _NetworkSettings();

  @override
  State<_NetworkSettings> createState() => _NetworkSettingsState();
}

class _NetworkSettingsState extends State<_NetworkSettings> {
  final _proxyFieldController = TextEditingController();
  final _hostFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _proxyFieldController.text = context.read<SettingProxy>().value ?? '';
    _hostFieldController.text = context.read<BungaServerHost>().value;
  }

  @override
  void dispose() {
    _proxyFieldController.dispose();
    _hostFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingStack(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionText('服务器'),
          _SectionContainer(
            child: Consumer3<BungaClient?, PendingBungaHost, BungaServerHost>(
              builder: (context, client, pending, host, child) => TextField(
                decoration: InputDecoration(
                  labelText: 'Bunga 服务器',
                  errorText: client == null && !pending.value
                      ? host.value.isEmpty
                          ? '设置服务器地址'
                          : '无法连接'
                      : null,
                  border: const OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ValueListenableBuilder(
                      valueListenable: _hostFieldController,
                      builder: (context, hostFieldValue, child) => pending.value
                          ? const SizedBox.square(
                              dimension: 36,
                              child: Center(
                                child: LoadingButtonIcon(),
                              ),
                            )
                          : hostFieldValue.text == client?.host
                              ? Icon(
                                  Icons.check,
                                  color: Colors.greenAccent,
                                  size: IconTheme.of(context).size,
                                )
                              : TextButton(
                                  onPressed: _connectToHost,
                                  child: const Text('连接'),
                                ),
                    ),
                  ),
                ),
                enabled: !pending.value,
                controller: _hostFieldController,
              ),
            ),
          ),
          const _SectionText('代理'),
          _SectionContainer(
            child: TextField(
              decoration: const InputDecoration(
                labelText: '网络代理',
                border: OutlineInputBorder(),
              ),
              controller: _proxyFieldController,
              onChanged: (value) => context.read<SettingProxy>().value =
                  value.isEmpty ? null : value,
            ),
          ),
        ],
      ),
    );
  }

  void _connectToHost() async {
    final newHost = _hostFieldController.text;
    final bungaClient = BungaClient(newHost);
    final clientId = context.read<ClientId>().value;

    final clientNotifier = context.read<BungaClientNotifier>();
    final pendingNotifier = context.read<PendingBungaHost>();
    final hostNotifier = context.read<BungaServerHost>();

    try {
      pendingNotifier.value = true;
      clientNotifier.value = null;

      await bungaClient.register(clientId);
      clientNotifier.value = bungaClient;
      hostNotifier.value = newHost;
    } catch (e) {
      logger.e('Create Bunga client failed: $e');
    } finally {
      pendingNotifier.value = false;
    }
  }
}

class _ReactionSettings extends StatefulWidget {
  const _ReactionSettings();

  @override
  State<_ReactionSettings> createState() => _ReactionSettingsState();
}

class _ReactionSettingsState extends State<_ReactionSettings> {
  late final _hueProvider = context.read<ClientColorHue>();
  late int _hue = _hueProvider.value;

  @override
  Widget build(BuildContext context) {
    return _SettingStack(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionText('个性化'),
          _SectionContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('弹幕颜色'),
                _ColorSlider(
                  value: _hue,
                  onChanged: (value) => setState(() {
                    _hue = value;
                  }),
                ),
                DanmakuText(
                  text: '测试弹幕样式',
                  hue: _hue,
                ),
              ],
            ),
          ),
          const _SectionText('行为'),
          _SectionContainer(
            padding: EdgeInsets.zero,
            child: Consumer<AutoJoinChannel>(
              builder: (context, autoJoinNotifier, child) => SwitchListTile(
                title: const Text('打开视频后自动加入房间'),
                value: autoJoinNotifier.value,
                onChanged: (value) => autoJoinNotifier.value = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Future.microtask(() => _hueProvider.value = _hue);
    super.dispose();
  }
}

class _ColorSlider extends StatelessWidget {
  final int value;
  final Function(int value) onChanged;

  static final _colors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 128, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 128, 255, 0),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 128),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 0, 128, 255),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 127, 0, 255),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 0, 127),
    const Color.fromARGB(255, 255, 0, 0),
  ];

  const _ColorSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: _colors),
        ),
        height: 15,
        child: SliderTheme(
          data: SliderThemeData(
            trackShape: SliderDenseTrackShape(),
            trackHeight: 16,
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            showValueIndicator: ShowValueIndicator.never,
            thumbShape: _ColorSliderThumbShape(),
          ),
          child: Slider(
            min: 0,
            max: 360,
            value: value.toDouble(),
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ),
      ),
    );
  }
}

class _ShortcutSettings extends StatefulWidget {
  const _ShortcutSettings();

  @override
  State<_ShortcutSettings> createState() => _ShortcutSettingsState();
}

class _ShortcutSettingsState extends State<_ShortcutSettings> {
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
  };

  late final ShortcutMapping _shortcutMapNotifier =
      context.read<ShortcutMapping>();
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
    return _SettingStack(
      actions: [
        OutlinedButton(
          onPressed: () => setState(() {
            _shortcutMap = Map.from(ShortcutMapping.defaultMapping);
          }),
          child: const Text('恢复默认键位'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('确定'),
        ),
      ],
      content: Column(
        children: [
          for (final category in _categories.entries)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionText(category.key),
                _SectionContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      for (final shortcut in category.value.entries)
                        _ShortcutListTile(
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
                        )
                    ].alternateWith(const Divider(height: 0)).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
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
      builder: (context) => Dialog(
        alignment: Alignment.topLeft,
        insetPadding: EdgeInsets.only(left: rect.left, top: rect.top),
        child: SizedBox.fromSize(
          size: rect.size,
          child: ListTile(
            title: Text(title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Text(
        _alternateLabel[logicalKey] ?? logicalKey.keyLabel,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AboutSetting extends StatelessWidget {
  const _AboutSetting();
  @override
  Widget build(BuildContext context) {
    return _SettingStack(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          SvgPicture.asset(
            'assets/images/icon.svg',
            width: 96,
          ),
          const SizedBox(height: 16),
          Text(
            getIt<PackageInfo>().appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('版本: ${getIt<PackageInfo>().version}'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: getIt<PackageInfo>().appName,
            ),
            child: const Text('查看许可'),
          ),
        ],
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _SectionContainer extends SingleChildStatelessWidget {
  final EdgeInsetsGeometry? padding;
  const _SectionContainer({super.child, this.padding});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: child!,
        ),
      ),
    );
  }
}

class _ColorSliderThumbShape extends RoundSliderThumbShape {
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = sliderTheme.thumbColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
