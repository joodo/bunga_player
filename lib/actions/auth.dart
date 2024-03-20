import 'package:bunga_player/providers/clients/clients.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/clients/bunga.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/auto_retry.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class AuthActions extends SingleChildStatefulWidget {
  const AuthActions({super.key, super.child});

  @override
  State<AuthActions> createState() => _AuthActionsState();
}

class _AuthActionsState extends SingleChildState<AuthActions> {
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
    final bungaHost = read<SettingBungaHost>().value;
    if (bungaHost.isEmpty) return;

    final clientID = read<SettingClientId>().value;
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
