import 'dart:convert';
import 'dart:math';

import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/restart/global_business.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'wrapper.dart';

class Console extends StatelessWidget {
  final TextEditingController logTextController;
  const Console({super.key, required this.logTextController});

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Logs': _LogView(logTextController: logTextController),
      'Variables': _VariablesView(),
      'Actions': _ActionView(),
    };

    final tabBar = TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: tabs.keys.map((key) => Tab(text: key)).toList(),
    );

    final positionNotifier = context.read<ConsolePositionNotifier>();
    final positionSegs = ValueListenableBuilder(
      valueListenable: positionNotifier,
      builder: (context, position, child) {
        return SegmentedButton<AxisDirection>(
          segments: [
            ButtonSegment(value: .left, icon: Icon(Icons.border_left)),
            ButtonSegment(value: .down, icon: Icon(Icons.border_bottom)),
            ButtonSegment(value: .right, icon: Icon(Icons.border_right)),
          ],
          selected: {position},
          onSelectionChanged: (value) => positionNotifier.value = value.first,
          showSelectedIcon: false,
        );
      },
    );

    final closeButton = CloseButton(
      onPressed: Actions.handler(context, ToggleConsoleIntent()),
    );

    final consoleView = DefaultTabController(
      length: tabs.length,
      child: [
        [
          tabBar.flexible(),
          positionSegs,
          closeButton,
        ].toRow(separator: const SizedBox(width: 8)),
        TabBarView(
          children: tabs.values
              .map((widget) => widget.padding(all: 8.0))
              .toList(),
        ).flexible(),
      ].toColumn(),
    );

    return consoleView;
  }
}

class _LogView extends StatelessWidget {
  final TextEditingController logTextController;

  const _LogView({required this.logTextController});

  @override
  Widget build(BuildContext context) {
    return [
      [
        SelectableText(logger.path).flexible(fit: .tight),
        OutlinedButton(
          onPressed: logTextController.clear,
          child: const Text('Clear'),
        ),
      ].toRow(separator: const SizedBox(width: 8.0)).padding(bottom: 8.0),
      TextField(
        controller: logTextController,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        style: Theme.of(context).textTheme.labelMedium,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        readOnly: true,
      ).flexible(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}

class _VariablesView extends StatefulWidget {
  @override
  State<_VariablesView> createState() => _VariablesViewState();
}

class _VariablesViewState extends State<_VariablesView> {
  @override
  Widget build(BuildContext context) {
    final service = getIt<ConsoleService>();
    // Variables
    final variables = Table(
      border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: service.watchingListenables.entries.map((entry) {
        final l = entry.value;
        late final Widget field;
        try {
          // Check disposed or not, a little bit dirty
          l.addListener(() {});
          l.removeListener(() {});

          field = ListenableBuilder(
            listenable: l,
            builder: (context, child) => _VariablesField(
              l is ValueListenable ? l.value.toString() : l.toString(),
            ),
          );
        } catch (_) {
          field = SelectableText('(disposed)');
        }

        return TableRow(
          children: [
            SelectableText(entry.key).padding(vertical: 8.0, horizontal: 16.0),
            field.padding(vertical: 8.0, horizontal: 16.0),
          ],
        );
      }).toList(),
    );

    // Preferences
    final pref = getIt<Preferences>();
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
                  SelectableText(
                    pref.get(key).toString(),
                  ).padding(vertical: 8.0, horizontal: 16.0),
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
      const Text(
        'Environment',
      ).textStyle(Theme.of(context).textTheme.titleMedium!),
      variables.padding(top: 8.0),
      const Text(
        'Preferences',
      ).textStyle(Theme.of(context).textTheme.titleMedium!).padding(top: 16.0),
      prefs.padding(top: 8.0),
    ].toColumn(crossAxisAlignment: .start).scrollable();
  }
}

class _VariablesField extends StatefulWidget {
  final String text;

  const _VariablesField(this.text);

  @override
  State<_VariablesField> createState() => _VariablesFieldState();
}

class _VariablesFieldState extends State<_VariablesField> {
  bool collapsed = true;

  @override
  Widget build(BuildContext context) {
    final content = collapsed ? widget.text : _tryPrettyJson(widget.text);

    return SelectableText(
      content,
      maxLines: collapsed ? 1 : null,
      onTap: () {
        setState(() {
          collapsed = !collapsed;
        });
      },
    );
  }

  String _tryPrettyJson(String input) {
    try {
      final dynamic data = jsonDecode(input);
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return input;
    }
  }
}

class _ActionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      FilledButton(
        onPressed: Actions.handler(context, RestartAppIntent()),
        child: const Text('Restart app'),
      ),
      FilledButton(
        onPressed: () => _changeClientID(context),
        child: const Text('Change Client ID'),
      ),
      FilledButton(
        onPressed: () => throw 'Exception!',
        child: const Text('Throw an exception'),
      ),
      FilledButton(
        onPressed: () =>
            getIt<Toast>().show('New toast: ${_randomSentence()}.'),
        child: const Text('Show a toast'),
      ),
      FilledButton(
        onPressed: context.read<BungaServerInfo>().refreshToken,
        child: const Text('Refresh Token'),
      ),
    ].toColumn(separator: const SizedBox(height: 8));
  }

  Future<void> _changeClientID(BuildContext context) async {
    final accountNotifier =
        getIt<ConsoleService>().watchingListenables['Client Account']
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
    final act = Actions.invoke(context, ConnectToHostIntent(host)) as Future;
    await act;

    getIt<Toast>().show('User ID has changed to $newID');
  }

  String _randomSentence() {
    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum';
    final split = lorem.split(RegExp(r'[,|.]'));
    final index = Random().nextInt(split.length);
    return split[index].trim();
  }
}
