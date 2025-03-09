import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/network/providers.dart';
import 'package:bunga_player/popmoji/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:bunga_player/play/providers.dart';

class GlobalBusiness extends SingleChildStatelessWidget {
  const GlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        networkProviders,
        uiProviders,
        const ClientInfoGlobalBusiness(),
        const BungaServerGlobalBusiness(),
        popmojiProviders,
        playerProviders,
        const VoiceCallGlobalBusiness(),
      ],
      child: child,
    );
  }
}
