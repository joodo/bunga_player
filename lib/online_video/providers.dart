import 'package:provider/provider.dart';

import '../bunga_server/client.dart';
import 'client.dart';

final onlineVideoProviders = MultiProvider(
  providers: [
    ProxyProvider<BungaClient?, OnlineVideoClient?>(
      update: (context, bungaClient, previous) =>
          bungaClient == null ? null : OnlineVideoClient(bungaClient),
      lazy: false,
    ),
  ],
);
