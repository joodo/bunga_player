import 'package:bunga_player/bunga_server/client.dart';
import 'package:provider/provider.dart';

import 'client.dart';

final alistProviders = MultiProvider(
  providers: [
    ProxyProvider<BungaClient?, AListClient?>(
      update: (context, bungaClient, previous) =>
          bungaClient?.aListClientInfo == null
              ? null
              : AListClient(
                  host: bungaClient!.aListClientInfo!.host,
                  token: bungaClient.aListClientInfo!.token,
                ),
      lazy: false,
    ),
  ],
);
