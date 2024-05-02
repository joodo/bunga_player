import 'package:bunga_player/alist/providers.dart';
import 'package:bunga_player/bunga_server/providers.dart';
import 'package:bunga_player/danmaku/providers.dart';
import 'package:bunga_player/network/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/online_video/providers.dart';
import 'package:bunga_player/client_info/providers.dart';

extension IsVideoSameWithChannel on BuildContext {
  bool get isVideoSameWithChannel =>
      read<ChatChannelData>().value?.videoHash ==
      read<PlayVideoEntry>().value?.hash;
}

class ProvidersWrapper extends SingleChildStatelessWidget {
  const ProvidersWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        clientInfoProviders,
        networkProviders,
        uiProviders,
        playerProviders,
        bungaServerProviders,
        alistProviders,
        onlineVideoProviders,
        channelJoiningProvider,
        chatProviders,
        danmakuProvider,
        voiceCallProviders,
        playSyncProvider,
      ],
      child: child,
    );
  }
}
