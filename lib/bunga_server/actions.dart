import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/auto_retry.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'providers.dart';

class BungaServerActions extends SingleChildStatefulWidget {
  const BungaServerActions({super.key, super.child});

  @override
  State<BungaServerActions> createState() => _BungaServerActionsState();
}

class _BungaServerActionsState extends SingleChildState<BungaServerActions> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryToCreateBungaClient();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Auth'),
      actions: const <Type, Action<Intent>>{},
      child: child!,
    );
  }

  void _tryToCreateBungaClient() async {
    final read = context.read;
    final bungaHost = read<BungaServerHost>().value;
    if (bungaHost.isEmpty) return;

    final clientID = read<ClientId>().value;
    final bungaClient = BungaClient(bungaHost);
    final pending = read<PendingBungaHost>();
    final job = AutoRetryJob(
      () => bungaClient.register(clientID),
      jobName: 'Create Bunga Client',
      alive: () => context.mounted,
      maxTries: 3,
    );

    try {
      pending.value = true;
      await job.run();
      read<BungaClientNotifier>().value = bungaClient;
    } catch (e) {
      getIt<Toast>().show('无法连接到服务器，请检查设置');
    } finally {
      pending.value = false;
    }
  }
}
