import 'package:bunga_player/alist/business.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/client_info/global_business.dart';
import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/network/global_business.dart';
import 'package:bunga_player/play/global_business.dart';
import 'package:bunga_player/restart/global_business.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/update/global_business.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class GlobalBusiness extends SingleChildStatelessWidget {
  const GlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Nested(
      children: [
        const RestartGlobalBusiness(),
        const UIGlobalBusiness(),
        const PopmojiGlobalBusiness(),
        const NetworkGlobalBusiness(),
        const PlayGlobalBusiness(),
        const ClientInfoGlobalBusiness(),
        const BungaServerGlobalBusiness(),
        const ChatGlobalBusiness(),
        const VoiceCallGlobalBusiness(),
        const AListGlobalBusiness(),
        const UpdateGlobalBusiness(),
      ],
      child: child,
    );
  }
}
