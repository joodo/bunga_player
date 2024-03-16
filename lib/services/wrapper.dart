import 'package:animations/animations.dart';
import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/screens/dialogs/host.dart';
import 'package:bunga_player/screens/widgets/loading_text.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'alist.dart';
import 'bunga.dart';
import 'call.agora.dart';
import 'call.dart';
import 'chat.dart';
import 'chat.stream_io.dart';
import 'online_video.dart';

class ServicesWrapper extends SingleChildStatefulWidget {
  const ServicesWrapper({super.key, super.child});

  @override
  State<ServicesWrapper> createState() => _ServicesWrapperState();
}

class _ServicesWrapperState extends SingleChildState<ServicesWrapper> {
  late final _getAppKeysJob = _getAppKeys();

  Future<AppKeys> _getAppKeys() async {
    final bungaHost = context.read<SettingBungaHost>();
    String hostUrl = bungaHost.value;

    do {
      try {
        final appKeys = await _initHost(hostUrl);
        bungaHost.value = hostUrl;
        return appKeys;
      } catch (e) {
        if (!mounted) throw Exception('Host wrapper context unmounted');

        logger.e('Host init failed: $e');

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
      }
    } while (true);
  }

  Future<AppKeys> _initHost(String host) async {
    final bungaService = Bunga(host);
    final appKey = AppKeys.fromJson(await bungaService.getAppKey());

    getIt.registerSingleton<Bunga>(bungaService);
    getIt.registerSingleton<ChatService>(StreamIO(appKey.streamIO));
    getIt.registerSingleton<CallService>(Agora(appKey.agora));
    getIt.registerSingleton<AList>(AList());
    getIt.registerSingleton<OnlineVideoService>(OnlineVideoService());

    return appKey;
  }

  @override
  void dispose() {
    getIt.unregister<Bunga>();
    getIt.unregister<ChatService>();
    getIt.unregister<CallService>();
    getIt.unregister<AList>();
    getIt.unregister<OnlineVideoService>();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return FutureBuilder(
      future: _getAppKeysJob,
      builder: (context, snapshot) =>
          snapshot.connectionState != ConnectionState.done
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 200,
                        child: Lottie.asset(
                          'assets/images/emojis/u1f416.json',
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const LoadingText('正在炼金'),
                    ],
                  ),
                )
              : Provider.value(
                  value: snapshot.data!,
                  child: child,
                ),
    );
  }
}
