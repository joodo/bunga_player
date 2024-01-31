import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/providers/states/voice_call.dart';
import 'package:bunga_player/services/agora.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/ui/toast.dart';
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
          create: (context) => RemotePlaying(context.read),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
