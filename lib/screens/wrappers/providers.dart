import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension IsVideoSameWithChannel on BuildContext {
  bool get isVideoSameWithChannel =>
      read<CurrentChannelData>().value?.videoHash ==
      read<PlayVideoEntry>().value?.hash;
}

class ProvidersWrapper extends StatelessWidget {
  const ProvidersWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(Object context) {
    return MultiProvider(
      providers: [
        settingProviders,
        uiProviders,
        chatProviders,
        playerProviders,
        ChangeNotifierProvider(create: (context) => BusinessIndicator()),
      ],
      child: child,
    );
  }
}
