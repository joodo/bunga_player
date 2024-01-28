import 'package:bunga_player/screens/dialogs/host.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

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

  Future<void> _init() async {
    final preferences = getService<Preferences>();
    String bungaHost = preferences.get('bunga_host') ?? '';

    bool success = false;
    do {
      try {
        await initHost(bungaHost);
        success = true;
      } catch (e) {
        logger.e(e);
        if (!context.mounted) return;
        bungaHost = await showDialog<String>(
              context: context,
              builder: (context) => HostDialog(host: bungaHost),
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
              ? const SizedBox.shrink()
              : widget.child,
    );
  }
}
