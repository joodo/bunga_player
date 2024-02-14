import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/providers/chat.dart' as chat;
import 'package:bunga_player/services/call.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension IsVideoSameWithChannel on BuildContext {
  bool get isVideoSameWithChannel =>
      read<CurrentChannelData>().value?.videoHash ==
      read<VideoPlayer>().videoHashNotifier.value;
}

class ProvidersWrapper extends StatelessWidget {
  const ProvidersWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(Object context) {
    return MultiProvider(
      providers: [
        ...uiProviders(),
        Provider(
            create: (context) => AppKey(
                  streamIO: getIt<ChatService>().appKey,
                  agora: getIt<CallService>().appId,
                )),
        chat.providers,
        ChangeNotifierProvider(create: (context) => BusinessIndicator()),
        Provider(create: (context) => VideoPlayer()),
      ],
      child: child,
    );
  }
}
