import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class ConsoleDialog extends StatefulWidget {
  final TextEditingController logTextController;
  const ConsoleDialog({super.key, required this.logTextController});

  @override
  State<ConsoleDialog> createState() => _ConsoleDialogState();
}

class _ConsoleDialogState extends State<ConsoleDialog> {
  @override
  Widget build(BuildContext context) {
    final logView = TextField(
      controller: widget.logTextController,
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
            final accountNotifier =
                getIt<ConsoleService>().watchingValueNotifiers['Client Account']
                    as ValueNotifier<ClientAccount>;

            final currentID = accountNotifier.value.id;
            final split = currentID.split('__');

            late final String newID;
            if (split.length == 1) {
              newID = '${currentID}__1';
            } else {
              newID = '${split.first}__${int.parse(split.last) + 1}';
            }

            final newAccount = ClientAccount(
              id: newID,
              password: accountNotifier.value.password,
            );
            accountNotifier.value = newAccount;

            final host = context.read<BungaHostAddress>().value;
            final act = Actions.invoke(
              context,
              ConnectToHostIntent(host),
            ) as Future;
            await act;

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
          onPressed: () => setState(context.read<PlayVideoSessions>().clearAll),
          child: Text(
              'Clear all watch progress (${context.read<PlayVideoSessions>().count})'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => AudioPlayer().play(
            AssetSource('sounds/call.mp3'),
            mode: PlayerMode.lowLatency,
          ),
          child: const Text('Play sound'),
        ),
      ],
    );

    final consoleView = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: 'Logs'),
              Tab(text: 'Variables'),
              Tab(text: 'Actions'),
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

    return consoleView;
  }

  String _randomSentence() {
    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum';
    final split = lorem.split(RegExp(r'[,|.]'));
    final index = Random().nextInt(split.length);
    return split[index].trim();
  }
}

class _VariablesView extends StatefulWidget {
  @override
  State<_VariablesView> createState() => _VariablesViewState();
}

class _VariablesViewState extends State<_VariablesView> {
  @override
  Widget build(BuildContext context) {
    // Variables
    final variables = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: getIt<ConsoleService>().watchingValueNotifiers.entries.map(
        (entry) {
          // Check disposed or not
          // ignore: invalid_use_of_protected_member
          final content = !entry.value.hasListeners
              ? const SelectableText('(disposed)')
              : ValueListenableBuilder(
                  valueListenable: entry.value,
                  builder: (context, value, child) =>
                      SelectableText(value.toString()),
                );

          return TableRow(
            children: [
              SelectableText(entry.key)
                  .padding(vertical: 8.0, horizontal: 16.0),
              content.padding(vertical: 8.0, horizontal: 16.0),
            ],
          );
        },
      ).toList(),
    );

    // Preferences
    final pref = getIt<Preferences>();
    const ellipsisKeys = ['history'];
    final prefs = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: pref.keys
          .sorted()
          .map(
            (key) => TableRow(
              children: [
                SelectableText(key).padding(vertical: 8.0, horizontal: 16.0),
                [
                  SelectableText(ellipsisKeys.contains(key)
                          ? '...'
                          : pref.get(key).toString())
                      .padding(vertical: 8.0, horizontal: 16.0),
                  TextButton(
                    onPressed: () async {
                      await pref.remove(key);
                      setState(() {});
                    },
                    child: const Text('unset'),
                  ),
                ].toWrap(crossAxisAlignment: WrapCrossAlignment.center),
              ],
            ),
          )
          .toList(),
    );

    return [
      const Text('Environment')
          .textStyle(Theme.of(context).textTheme.titleMedium!),
      variables.padding(top: 8.0),
      const Text('Preferences')
          .textStyle(Theme.of(context).textTheme.titleMedium!)
          .padding(top: 16.0),
      prefs.padding(top: 8.0),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).scrollable();
  }
}
