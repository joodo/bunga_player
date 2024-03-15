import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import 'channel.dart';
import 'danmaku.dart';
import 'play.dart';
import 'ui.dart';
import 'video_playing.dart';
import 'voice_call.dart';

class ActionsLeaf {
  late BuildContext _leafContext;
  void registerContext(BuildContext context) => _leafContext = context;

  Object? mayBeInvoke(Intent intent) =>
      Actions.maybeInvoke(_leafContext, intent);
  Object? invoke(Intent intent) => Actions.invoke(_leafContext, intent);
}

class ActionsWrapper extends Nested {
  ActionsWrapper({super.key, super.child})
      : super(children: [
          Provider(create: (context) => ActionsLeaf()),
          const UIActions(),
          const PlayActions(),
          const AuthActions(),
          const ChannelActions(),
          const VideoPlayingActions(),
          const VoiceCallActions(),
          const DanmakuActions(),
          SingleChildBuilder(builder: (context, child) {
            context.read<ActionsLeaf>().registerContext(context);
            return child!;
          }),
        ]);
}
