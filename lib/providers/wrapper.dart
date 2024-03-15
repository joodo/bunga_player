import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'settings.dart';
import 'ui.dart';
import 'chat.dart';
import 'player.dart';

extension IsVideoSameWithChannel on BuildContext {
  bool get isVideoSameWithChannel =>
      read<CurrentChannelData>().value?.videoHash ==
      read<PlayVideoEntry>().value?.hash;
}

class ProvidersWrapper extends SingleChildStatelessWidget {
  const ProvidersWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        settingProviders,
        uiProviders,
        chatProviders,
        playerProviders,
      ],
      child: child,
    );
  }
}
