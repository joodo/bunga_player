import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/current_channel.dart';
import 'package:bunga_player/providers/current_user.dart';
import 'package:bunga_player/providers/player_controller.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/video_player.dart';
import 'package:bunga_player/providers/voice_call.dart';
import 'package:bunga_player/services/agora.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/toast.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProvidersWrapper extends StatelessWidget {
  const ProvidersWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(Object context) {
    return MultiProvider(
      providers: [
        ...uiProviders(),
        Provider(create: (context) => Toast(context)),
        Provider(
            create: (context) => AppKey(
                  streamIO: getService<StreamIO>().appKey,
                  agora: getService<Agora>().appId,
                )),
        ChangeNotifierProvider(create: (context) => CurrentUser(context.read)),
        ChangeNotifierProvider(
            create: (context) => CurrentChannel(context.read)),
        ChangeNotifierProvider(create: (context) => VoiceCall(context.read)),
        Provider(create: (context) => VideoPlayer()),
        Provider(
          create: (context) => PlayerController(context.read),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
