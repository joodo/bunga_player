import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/screens/dialogs/host.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HostInitWrapper extends StatefulWidget {
  final Widget child;

  const HostInitWrapper({super.key, required this.child});

  @override
  State<HostInitWrapper> createState() => _HostInitWrapperState();
}

class _HostInitWrapperState extends State<HostInitWrapper> {
  late final Future<void> _initTask;

  @override
  void initState() {
    super.initState();
    _initTask = _init();
  }

  late AppKeys _appKeys;
  Future<void> _init() async {
    final preferences = getIt<Preferences>();
    String bungaHost = preferences.get('bunga_host') ?? '';

    bool success = false;
    do {
      try {
        _appKeys = await initHost(bungaHost);
        success = true;
      } catch (e) {
        if (!mounted) return;
        bungaHost = await showDialog<String>(
              context: context,
              builder: (dialogContext) => HostDialog(
                host: bungaHost,
                error: e.toString(),
                proxy: context.read<SettingProxy>(),
              ),
              barrierDismissible: false,
            ) ??
            '';
      }
    } while (!success);

    preferences.set('bunga_host', bungaHost);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initTask,
      builder: (context, snapshot) =>
          snapshot.connectionState != ConnectionState.done
              ? const Center(child: Text('正在炼金'))
              : Provider.value(
                  value: _appKeys,
                  child: widget.child,
                ),
    );
  }
}
