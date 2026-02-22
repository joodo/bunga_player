import 'dart:convert';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/client_info/global_business.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/screens/player_screen/player_widget/vibe_layer/danmaku.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/channel_tokens.dart';

class ReactionSettings extends StatefulWidget with SettingsTab {
  @override
  final label = '互动';
  @override
  final icon = Icons.chat_outlined;
  @override
  final selectedIcon = Icons.chat;

  const ReactionSettings({super.key});

  @override
  State<ReactionSettings> createState() => _ReactionSettingsState();
}

class _ReactionSettingsState extends State<ReactionSettings> {
  late final _nicknameNotifier = context.read<ClientNicknameNotifier>();
  late final _hueProvider = context.read<ClientColorHueNotifier>();
  late int _hue = _hueProvider.value;

  @override
  Widget build(BuildContext context) {
    return [
      const Text('频道').sectionTitle(),
      const _ChannelSwitcher().sectionContainer(),
      const Text('个性化').sectionTitle(),
      InputBuilder(
        builder: (context, textEditingController, focusNode, child) =>
            TextField(
              decoration: const InputDecoration(
                labelText: '昵称',
                border: OutlineInputBorder(),
              ),
              controller: textEditingController,
              focusNode: focusNode,
            ),
        initValue: _nicknameNotifier.value,
        onFocusLose: (controller) {
          _nicknameNotifier.value = controller.text;
        },
      ).padding(all: 16.0).sectionContainer(),
      [
            const Text('弹幕颜色'),
            _ColorSlider(
              value: _hue,
              onChanged: (value) => setState(() {
                _hue = value;
              }),
              onChangeEnd: (value) {
                _hueProvider.value = _hue;
              },
            ),
            _DanmakuPreview(hue: _hue),
          ]
          .toColumn(crossAxisAlignment: .start)
          .padding(all: 16.0)
          .sectionContainer(),
    ].toColumn(crossAxisAlignment: .start);
  }
}

class _ChannelSwitcher extends StatefulWidget {
  const _ChannelSwitcher();
  @override
  State<_ChannelSwitcher> createState() => _ChannelSwitcherState();
}

typedef ChannelInfo = ({String name, String url});

class _ChannelSwitcherState extends State<_ChannelSwitcher> {
  static const _prefKey = 'channel_infos';

  final _channelInfos = <ChannelInfo>[];

  bool _tryFailed = false;

  @override
  void initState() {
    super.initState();
    _loadInfos();
  }

  @override
  void dispose() {
    _saveInfos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return [
      Consumer2<ChannelTokens?, FetchingChannelTokens>(
        builder: (context, channelTokens, fetching, child) => InputBuilder(
          builder: (context, textEditingController, focusNode, child) {
            final awaitToFill = channelTokens == null && !fetching.value;
            return TextField(
              decoration: InputDecoration(
                labelText: '添加服务器',
                errorText: _tryFailed
                    ? '无法连接'
                    : awaitToFill
                    ? '设置服务器地址'
                    : null,
                border: const OutlineInputBorder(),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: textEditingController,
                  builder: (context, textValue, child) => fetching.value
                      ? const LoadingButtonIcon().center().constrained(
                          width: 36.0,
                          height: 36.0,
                        )
                      : TextButton(
                          onPressed: () async {
                            final success = await _addServer(textValue.text);
                            if (success) textEditingController.clear();
                          },
                          child: const Text('连接'),
                        ),
                ).padding(right: 8.0),
              ),
              enabled: !fetching.value,
              controller: textEditingController,
            );
          },
        ),
      ).padding(all: 16.0),
      if (_channelInfos.isNotEmpty) const Divider(),
      if (_channelInfos.isNotEmpty) _createRadios(),
    ].toColumn();
  }

  Widget _createRadios() {
    return Consumer2<BungaHostAddress?, FetchingChannelTokens>(
      builder: (context, hostAddress, isFetching, child) {
        // Have address, but didn't get tokens,
        // that means current server unalivable
        final currentUnalivable =
            context.read<BungaHostAddress>().value.isNotEmpty &&
            context.read<ChannelTokens?>() == null;
        final errorColor = Theme.of(context).colorScheme.error;
        return RadioGroup<String>(
          groupValue: hostAddress?.value,
          onChanged: (url) {
            _connectTo(url!);
          },
          child: _channelInfos
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final info = entry.value;
                final selected = hostAddress?.value == info.url;

                final error = selected && currentUnalivable;

                final controller = MenuController();
                return RadioListTile(
                  enabled: !isFetching.value,
                  value: info.url,
                  title: error
                      ? Text('${info.name} （不可用）').textColor(errorColor)
                      : Text(info.name),
                  subtitle: Text(
                    Uri.parse(info.url).origin,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  activeColor: error ? errorColor : null,
                  secondary: MenuAnchor(
                    controller: controller,
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(info.url),
                        child: const Text('复制地址'),
                      ),
                      MenuItemButton(
                        leadingIcon: Icon(Icons.delete),
                        onPressed: selected ? null : () => _remove(index),
                        child: const Text('删除'),
                      ),
                      if (error)
                        MenuItemButton(
                          leadingIcon: Icon(Icons.cached),
                          onPressed: () => _connectTo(info.url),
                          child: const Text('重试'),
                        ),
                    ],
                    child: IconButton(
                      onPressed: controller.open,
                      icon: Icon(Icons.more_horiz),
                    ),
                  ),
                );
              })
              .toList()
              .toColumn(),
        );
      },
    );
  }

  void _loadInfos() {
    try {
      final strings = getIt<Preferences>().get<List<String>>(_prefKey);
      if (strings == null) return;

      _channelInfos.addAll(
        strings.map((e) {
          final json = jsonDecode(e);
          return (name: json['name'], url: json['url']);
        }),
      );
    } catch (e) {
      logger.w('Channel Info: failed loading ($e)');
    }
  }

  void _saveInfos() {
    getIt<Preferences>().set(
      _prefKey,
      _channelInfos.map((info) {
        final json = {'name': info.name, 'url': info.url};
        return jsonEncode(json);
      }).toList(),
    );
  }

  void _copyToClipboard(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) context.popBar('已复制到剪切板');
  }

  Future<bool> _addServer(String url) async {
    final result = await _connectTo(url);

    if (!mounted) return false;

    if (result != null) {
      setState(() {
        if (!_channelInfos.any((info) => info.url == url)) {
          _channelInfos.add((name: result.channel.name, url: url));
        }
        _tryFailed = false;
      });
      context.popBar('添加成功');
      return true;
    } else {
      setState(() {
        _tryFailed = true;
      });
      return false;
    }
  }

  Future<ChannelTokens?> _connectTo(String url) {
    return Actions.invoke(context, ConnectToHostIntent(url))
        as Future<ChannelTokens?>;
  }

  void _remove(int index) {
    final deletedItem = _channelInfos[index];
    setState(() {
      _channelInfos.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除 ${deletedItem.name}'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() {
              _channelInfos.insert(index, deletedItem);
            });
          },
        ),
      ),
    );
  }
}

class _DanmakuPreview extends StatefulWidget {
  static const text = '测试弹幕样式';

  final int hue;
  const _DanmakuPreview({required this.hue});

  @override
  State<_DanmakuPreview> createState() => _DanmakuPreviewState();
}

class _DanmakuPreviewState extends State<_DanmakuPreview> {
  late DanmakuTextPainter _painter;

  @override
  void initState() {
    super.initState();
    _painter = DanmakuTextPainter(
      message: _DanmakuPreview.text,
      hue: widget.hue,
    );
  }

  @override
  void didUpdateWidget(covariant _DanmakuPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hue != widget.hue) {
      _painter.updateColor(widget.hue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DanmakuPainter(_painter), size: _painter.size);
  }
}

class _DanmakuPainter extends CustomPainter {
  final DanmakuTextPainter dp;
  _DanmakuPainter(this.dp);

  @override
  void paint(Canvas canvas, Size size) {
    dp.strokePainter.paint(canvas, Offset.zero);
    dp.fillPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _DanmakuPainter oldDelegate) => true;
}

class _ColorSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged, onChangeEnd;

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

  const _ColorSlider({required this.value, this.onChanged, this.onChangeEnd});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
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
            onChanged: (value) => onChanged?.call(value.toInt()),
            onChangeEnd: (value) => onChangeEnd?.call(value.toInt()),
          ),
        )
        .decorated(
          border: Border.all(width: 2, color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: _colors),
        )
        .constrained(height: 15.0)
        .padding(horizontal: 0, vertical: 16.0);
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
