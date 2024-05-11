import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/bunga_server/actions.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/danmaku/actions.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/ui/actions.dart';
import 'package:bunga_player/play_sync/actions.dart';
import 'package:bunga_player/voice_call/actions.dart';

class ActionsLeaf {
  late BuildContext _leafContext;
  void registerContext(BuildContext context) => _leafContext = context;

  Object? mayBeInvoke(Intent intent) =>
      Actions.maybeInvoke(_leafContext, intent);
  Object? invoke(Intent intent) => Actions.invoke(_leafContext, intent);
  Object? maybeInvoke(Intent intent) =>
      Actions.maybeInvoke(_leafContext, intent);
}

class ActionsWrapper extends SingleChildStatelessWidget {
  const ActionsWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Nested(
      children: [
        Provider(create: (context) => ActionsLeaf()),
        const UIActions(),
        const PlayActions(),
        const BungaServerActions(),
        const ChatActions(),
        const PlaySyncActions(),
        const VoiceCallActions(),
        const DanmakuActions(),
        SingleChildBuilder(builder: (context, child) {
          context.read<ActionsLeaf>().registerContext(context);
          return child!;
        }),
      ],
      child: child,
    );
  }
}
