import 'dart:async';
import 'dart:convert';

import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/services/tokens.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/services/voice_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Console extends StatefulWidget {
  final Widget child;
  const Console({super.key, required this.child});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  bool _show = false;
  final _logTextController = TextEditingController();
  late final StreamSubscription _subscribe;

  @override
  void initState() {
    super.initState();
    _subscribe = loggerStream.listen((logs) {
      _logTextController.text += '${logs.join('\n')}\n';
    });
  }

  @override
  void dispose() {
    _subscribe.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logView = TextField(
      controller: _logTextController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      style: Theme.of(context).textTheme.labelMedium,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      readOnly: true,
    );

    final actionView = Column(
      children: [
        FilledButton(
          onPressed: () async {
            final currentID = Tokens().bunga.clientID;
            final split = currentID.split('__');

            late final String newID;
            if (split.length == 1) {
              newID = '${currentID}__1';
            } else {
              newID = '${split.first}__${int.parse(split.last) + 1}';
            }

            await Tokens().setClientID(newID);
            await Chat().updateLoginInfo();

            showSnackBar('Update to $newID');
          },
          child: const Text('Change user id'),
        ),
      ],
    );

    final consoleView = DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xA0000000),
        appBar: AppBar(
          title: Row(
            children: [
              const Expanded(
                child: TabBar(
                  tabs: [
                    Tab(text: 'Logs'),
                    Tab(text: 'Variables'),
                    Tab(text: 'Actions'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _show = false;
                }),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: logView,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _VariablesView(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: actionView,
            ),
          ],
        ),
      ),
    );

    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.f12) {
          setState(() {
            _show = !_show;
          });
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Visibility(
            visible: _show,
            child: consoleView,
          ),
        ],
      ),
    );
  }
}

Widget _padding(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: child,
    );

class _VariablesView extends StatelessWidget {
  final _jsonEncoder = const JsonEncoder.withIndent('  ');

  late final _variables = <String, Future<String?> Function()>{
    'Current verion': () async {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    },
    'Tokens': () => Future.value(_jsonEncoder.convert({
          'bunga': Tokens().bunga.toJson(),
          'stream': Tokens().streamIO.toJson(),
          'agora': Tokens().agora.toJson(),
        })),
    'Chat User Name': () => Future.value(Chat().currentUserNameNotifier.value),
    'Chat Channel': () => Future.value(_jsonEncoder.convert({
          'id': Chat().currentChannelNotifier.value?.id,
          if (Chat().currentChannelNotifier.value != null)
            ...Chat().currentChannelNotifier.value!.extraData,
        })),
    'Video Hash': () => Future.value(VideoPlayer().videoHashNotifier.value),
    'Call Status': () =>
        Future.value(VoiceCall().callStatusNotifier.value.name),
  };

  @override
  Widget build(BuildContext context) {
    final variables = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: _variables.entries
          .map(
            (row) => TableRow(
              children: [
                _padding(Text(row.key)),
                _TableValue(func: row.value),
              ],
            ),
          )
          .toList(),
    );

    final prefs = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: Preferences().keys.map((key) {
        if (key == 'watch_progress') {
          return TableRow(
            children: [
              _padding(Text(key)),
              _padding(const Text('...')),
            ],
          );
        }
        return TableRow(
          children: [
            _padding(Text(key)),
            _padding(Text(Preferences().get(key).toString())),
          ],
        );
      }).toList(),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          variables,
          const SizedBox(height: 16),
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          prefs,
        ],
      ),
    );
  }
}

class _TableValue extends StatefulWidget {
  final Future<String?> Function() func;

  const _TableValue({required this.func});

  @override
  State<_TableValue> createState() => _TableValueState();
}

class _TableValueState extends State<_TableValue> {
  bool _isHovered = false;
  String? _text;

  @override
  void initState() {
    super.initState();
    widget.func().then((value) => setState(() {
          _text = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        _isHovered = true;
      }),
      onExit: (event) => setState(() {
        _isHovered = false;
      }),
      child: Stack(
        children: [
          _padding(SizedBox(
            width: double.maxFinite,
            child: Text(_text ?? ''),
          )),
          Visibility(
            visible: _isHovered,
            child: Positioned(
              right: 0,
              child: Row(
                children: [
                  Visibility(
                    visible: _text != null,
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _text!));
                        showSnackBar('已复制');
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => widget.func().then((value) => setState(() {
                          _text = value;
                        })),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
