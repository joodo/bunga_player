import 'package:animations/animations.dart';
import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/screens/dialogs/host.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class HostInitWrapper extends SingleChildStatefulWidget {
  const HostInitWrapper({super.key, super.child});

  @override
  State<HostInitWrapper> createState() => _HostInitWrapperState();
}

class _HostInitWrapperState extends SingleChildState<HostInitWrapper> {
  late final Future<void> _initTask;

  @override
  void initState() {
    super.initState();
    _initTask = _init();
  }

  late final AppKeys _appKeys;
  Future<void> _init() async {
    final bungaHost = context.read<SettingBungaHost>();
    String hostUrl = bungaHost.value;

    bool success = false;
    do {
      try {
        _appKeys = await initHost(hostUrl);
        success = true;
      } catch (e) {
        if (!mounted) return;
        hostUrl = await showModal<String>(
              context: context,
              configuration: const FadeScaleTransitionConfiguration(
                  barrierDismissible: false),
              builder: (dialogContext) => HostDialog(
                host: hostUrl,
                error: '连接失败',
                proxy: context.read<SettingProxy>(),
              ),
            ) ??
            '';
        logger.e(e);
      }
    } while (!success);

    bungaHost.value = hostUrl;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return FutureBuilder(
      future: _initTask,
      builder: (context, snapshot) =>
          snapshot.connectionState != ConnectionState.done
              ? const Center(child: Text('正在炼金'))
              : Provider.value(
                  value: _appKeys,
                  child: child,
                ),
    );
  }
}
