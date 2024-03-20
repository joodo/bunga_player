import 'package:bunga_player/providers/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'alist.dart';
import 'bunga.dart';
import 'call.agora.dart';
import 'call.dart';
import 'chat.dart';
import 'chat.stream_io.dart';
import 'online_video.dart';

class BungaClientNotifier extends ValueNotifier<BungaClient?> {
  BungaClientNotifier() : super(null);
}

final clientProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(
        create: (context) => BungaClientNotifier(), lazy: false),
    ProxyProvider<BungaClientNotifier, BungaClient?>(
      update: (context, notifier, previous) => notifier.value,
    ),
    ProxyProvider<BungaClient?, AListClient?>(
      update: (context, bungaClient, previous) =>
          bungaClient?.aListClientInfo == null
              ? null
              : AListClient(
                  host: bungaClient!.aListClientInfo!.host,
                  token: bungaClient.aListClientInfo!.token,
                ),
    ),
    ProxyProvider<BungaClient?, OnlineVideoClient?>(
      update: (context, bungaClient, previous) =>
          bungaClient == null ? null : OnlineVideoClient(bungaClient),
    ),
    ProxyProvider<BungaClient?, ChatClient?>(
      update: (context, bungaClient, previous) {
        return bungaClient == null
            ? null
            : StreamIOClient(bungaClient.streamIOClientInfo.appKey);
      },
    ),
    ProxyProvider<BungaClient?, CallClient?>(
      update: (context, bungaClient, previous) => bungaClient == null
          ? null
          : AgoraClient(
              bungaClient.agoraClientAppKey,
              volume: context.read<SettingCallVolume>().value.percent,
              noiseSuppressionLevel:
                  context.read<SettingCallNoiseSuppressionLevel>().value,
            ),
    ),
  ],
);
