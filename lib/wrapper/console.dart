import 'dart:convert';

import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/services/voice_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

Widget _padding(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: child,
    );
Widget _jsonText(Map<String, dynamic>? json) =>
    Text(const JsonEncoder.withIndent('  ').convert(json));

class Console extends StatefulWidget {
  final Widget child;
  const Console({super.key, required this.child});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  bool _show = false;
  final _logTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loggerStream.stream.listen((logs) {
      _logTextController.text += '${logs.join('\n')}\n';
    });
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

    final variableWidgets = <String, Widget>{
      'Current verion': FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) => Text(snapshot.data?.version ?? ''),
      ),
      'Chat User': ValueListenableBuilder(
        valueListenable: Chat().currentUserNotifier,
        builder: (context, value, child) => _jsonText(value?.toJson()),
      ),
      'Chat Channel': ValueListenableBuilder(
        valueListenable: Chat().currentChannelNotifier,
        builder: (context, value, child) => _jsonText(value == null
            ? null
            : {
                'id': value.id,
                ...value.extraData,
              }),
      ),
      'Video Hash': ValueListenableBuilder(
        valueListenable: VideoPlayer().videoHashNotifier,
        builder: (context, value, child) => Text(value ?? 'null'),
      ),
      'Call Status': ValueListenableBuilder(
        valueListenable: VoiceCall().callStatusNotifier,
        builder: (context, value, child) => Text(value.name),
      ),
      'Preferences': _PrefView(),
    };
    final tableView = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: variableWidgets.entries
          .map(
            (row) => TableRow(
              children: [
                _padding(Text(row.key)),
                _padding(row.value),
              ],
            ),
          )
          .toList(),
    );
    final variableView = SingleChildScrollView(
      child: tableView,
    );

    final consoleView = DefaultTabController(
      length: 2,
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
              child: variableView,
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

class _PrefView extends StatefulWidget {
  @override
  State<_PrefView> createState() => _PrefViewState();
}

class _PrefViewState extends State<_PrefView> {
  @override
  Widget build(BuildContext context) {
    final map = Preferences().getAll().map<String, Object?>((key, value) {
      switch (key) {
        case 'watch_progress':
          return MapEntry(key, jsonDecode(value as String? ?? ''));
        default:
          return MapEntry(key, value);
      }
    });

    final s = const JsonEncoder.withIndent('  ').convert(map);

    return Stack(
      children: [
        Positioned(
          right: 0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    Preferences().reload().then((value) => setState(() => {})),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: s));
                  showSnackBar('已复制');
                },
              ),
            ],
          ),
        ),
        Text(s),
      ],
    );
  }
}
