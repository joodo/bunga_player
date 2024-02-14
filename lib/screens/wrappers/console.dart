import 'dart:async';

import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/dialogs/host.dart';
import 'package:bunga_player/screens/wrappers/restart.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ConsoleWrapper extends StatefulWidget {
  final Widget child;
  const ConsoleWrapper({super.key, required this.child});

  @override
  State<ConsoleWrapper> createState() => _ConsoleWrapperState();
}

class _ConsoleWrapperState extends State<ConsoleWrapper> {
  bool _show = false;
  final _logTextController = TextEditingController();
  late final StreamSubscription _subscribe;

  @override
  void initState() {
    super.initState();
    _subscribe = logger.stream.listen((logs) {
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

    final watchProgress = context.read<VideoPlayer>().watchProgress;
    final actionView = Column(
      children: [
        FilledButton(
          onPressed: () async {
            final currentUser = context.read<CurrentUser>().value!;

            final currentID = currentUser.id;
            final split = currentID.split('__');

            late final String newID;
            if (split.length == 1) {
              newID = '${currentID}__1';
            } else {
              newID = '${split.first}__${int.parse(split.last) + 1}';
            }

            await (Actions.invoke(context, ChangeCurrentUserIdIntent(newID))
                as Future);
            getIt<Toast>().show('User ID has changed to $newID');
          },
          child: const Text('Change User ID'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () async {
            final preferences = getIt<Preferences>();
            final newHost = await showDialog<String>(
              context: context,
              builder: (context) =>
                  HostDialog(host: preferences.get('bunga_host')),
            );

            if (newHost == null || !context.mounted) return;
            preferences.set('bunga_host', newHost);
            unregisterHost();
            RestartWrapper.restartApp(context);
          },
          child: const Text('Change Bunga Host'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => throw 'Exception!',
          child: const Text('Throw an exception'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => getIt<Toast>().show('A new toast!'),
          child: const Text('Show a toast'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            setState(() {
              watchProgress.clear();
            });
          },
          child: Text('Clear all watch progress (${watchProgress.length})'),
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

class _VariablesView extends StatefulWidget {
  @override
  State<_VariablesView> createState() => _VariablesViewState();
}

class _VariablesViewState extends State<_VariablesView> {
  late final _variables = <String, String? Function(BuildContext context)>{
    'App Key': (context) => context.read<AppKey>().toString(),
    'Current verion': (context) => getIt<PackageInfo>().version,
    'Chat User': (context) => context.read<CurrentUser>().toString(),
    'Chat Channel': (context) =>
        'id: ${context.read<CurrentChannelId>().value}\ndata: ${context.read<CurrentChannelData>().value}\nwatchers:${context.read<CurrentChannelWatchers>().value}\nlast message: ${context.read<CurrentChannelMessage>().value}',
    'Voice Call': (context) =>
        'status: ${context.read<CurrentCallStatus>().value.name}\n talkers: ${context.read<CurrentTalkersCount>().value}',
    'Video Hash': (context) =>
        context.read<VideoPlayer>().videoHashNotifier.value ??
        'No Video Playing',
    'AList': (context) =>
        'host: ${getIt<AList>().host},\ntoken: ${getIt<AList>().token}',
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
                _padding(SelectableText(row.key)),
                _TableValue(func: row.value),
              ],
            ),
          )
          .toList(),
    );

    final pref = getIt<Preferences>();
    final prefs = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: pref.keys.map((key) {
        final content = key == 'watch_progress'
            ? const Text('...')
            : SelectableText(pref.get(key).toString());
        return TableRow(
          children: [
            _padding(SelectableText(key)),
            Row(children: [
              _padding(content),
              TextButton(
                onPressed: () async {
                  await pref.remove(key);
                  setState(() {});
                },
                child: const Text('unset'),
              ),
            ]),
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
  final String? Function(BuildContext context) func;

  const _TableValue({required this.func});

  @override
  State<_TableValue> createState() => _TableValueState();
}

class _TableValueState extends State<_TableValue> {
  bool _isHovered = false;
  late String? _text = widget.func(context);

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
            child: SelectableText(_text ?? ''),
          )),
          Visibility(
            visible: _isHovered,
            child: Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {
                  _text = widget.func(context);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
