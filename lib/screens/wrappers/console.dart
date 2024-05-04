import 'dart:async';
import 'dart:math';

import 'package:bunga_player/bunga_server/providers.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/alist/client.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ConsoleWrapper extends SingleChildStatefulWidget {
  const ConsoleWrapper({super.key, super.child});

  @override
  State<ConsoleWrapper> createState() => _ConsoleWrapperState();
}

class _ConsoleWrapperState extends SingleChildState<ConsoleWrapper> {
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
  Widget buildWithChild(BuildContext context, Widget? child) {
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
            final clientIdNotifier = context.read<ClientId>();

            final currentID = clientIdNotifier.value;
            final split = currentID.split('__');

            late final String newID;
            if (split.length == 1) {
              newID = '${currentID}__1';
            } else {
              newID = '${split.first}__${int.parse(split.last) + 1}';
            }

            final bungaClientNotifier = context.read<BungaClientNotifier>();
            final host = bungaClientNotifier.value?.host;
            if (host == null) {
              getIt<Toast>().show('Bunga Client not created yet');
              return;
            }

            final bungaClient = BungaClient(host);
            await bungaClient.register(newID);
            bungaClientNotifier.value = bungaClient;
            clientIdNotifier.value = newID;

            getIt<Toast>().show('User ID has changed to $newID');
          },
          child: const Text('Change Client ID'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => throw 'Exception!',
          child: const Text('Throw an exception'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () =>
              getIt<Toast>().show('New toast: ${_randomSentence()}.'),
          child: const Text('Show a toast'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => setState(() {
            getIt<Player>().watchProgresses.clearAll();
          }),
          child: Text(
              'Clear all watch progress (${getIt<Player>().watchProgresses.count})'),
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
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
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
          if (child != null) child,
          Visibility(
            visible: _show,
            child: consoleView,
          ),
        ],
      ),
    );
  }

  String _randomSentence() {
    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum';
    final split = lorem.split(RegExp(r'[,|.]'));
    final index = Random().nextInt(split.length);
    return split[index].trim();
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
  late final _variables = <String, String Function(BuildContext context)>{
    'Client id': (context) => context.read<ClientId>().value,
    'App Keys': (context) {
      final bunga = context.read<BungaClient?>();
      if (bunga == null) return 'null';
      return 'StreamIO: ${bunga.chatClientInfo.appKey}, Agora: ${bunga.agoraClientAppKey}, Bili sess: ${bunga.biliSess}';
    },
    'Current verion': (context) => getIt<PackageInfo>().version,
    'Chat User': (context) => context.read<ChatUser>().toString(),
    'Chat Channel': (context) => '''id: ${context.read<ChatChannel>().value?.id}
data: ${context.read<ChatChannelData>().value}
watchers:${context.read<ChatChannelWatchers>().value}
last message: ${context.read<ChatChannelLastMessage>().value}''',
    'Voice Call': (context) =>
        '''status: ${context.read<VoiceCallStatus>().value.name}
talkers: ${context.read<VoiceCallTalkers>().value}''',
    'Player': (context) =>
        '''Video Entry: ${context.read<PlayVideoEntry>().value}
Status: ${context.read<PlayStatus>().value}''',
    'AList': (context) => '${context.read<AListClient?>()}',
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
                _padding(SelectableText(row.value(context))),
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
            Wrap(
              children: [
                _padding(content),
                TextButton(
                  onPressed: () async {
                    await pref.remove(key);
                    setState(() {});
                  },
                  child: const Text('unset'),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Environment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() {}),
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
