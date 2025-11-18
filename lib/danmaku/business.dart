import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/services/preferences.dart';

import 'models/data.dart';

// Data types

class RecentPopmojisNotifier extends ValueNotifier<List<String>> {
  RecentPopmojisNotifier()
    : super(["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"]) {
    bindPreference<List<String>>(
      key: 'recent_popmojis',
      load: (pref) => value,
      update: (value) => value,
    );
  }
}

// Actions

@immutable
class SendPopmojiIntent extends Intent {
  final String code;
  const SendPopmojiIntent(this.code);
}

class SendPopmojiAction extends ContextAction<SendPopmojiIntent> {
  @override
  void invoke(SendPopmojiIntent intent, [BuildContext? context]) {
    final messageData = PopmojiMessageData(
      popmojiCode: intent.code,
      sender: User.fromContext(context!),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }
}

@immutable
class SendDanmakuIntent extends Intent {
  final String message;
  const SendDanmakuIntent(this.message);
}

class SendDanmakuAction extends ContextAction<SendDanmakuIntent> {
  @override
  void invoke(SendDanmakuIntent intent, [BuildContext? context]) {
    final messageData = DanmakuMessageData(
      message: intent.message,
      sender: User.fromContext(context!),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }
}

// Wrapper

class DanmakuBusiness extends SingleChildStatefulWidget {
  const DanmakuBusiness({super.key, super.child});

  @override
  State<DanmakuBusiness> createState() => _DanmakuBusinessState();
}

class _DanmakuBusinessState extends SingleChildState<DanmakuBusiness> {
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecentPopmojisNotifier()),
      ],
      child: child!.actions(
        actions: {
          SendPopmojiIntent: SendPopmojiAction(),
          SendDanmakuIntent: SendDanmakuAction(),
        },
      ),
    );
  }
}

extension WrapDanmakuBusiness on Widget {
  Widget danmakuBusiness() => DanmakuBusiness(child: this);
}

class PopmojiGlobalBusiness extends SingleChildStatelessWidget {
  const PopmojiGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        FutureProvider<EmojiData?>(
          create: (context) async {
            String jsonString = await DefaultAssetBundle.of(
              context,
            ).loadString('assets/emojis/emojis.json');
            final data = EmojiData.fromJson(jsonDecode(jsonString));

            _preCacheEmojis(data);

            return data;
          },
          initialData: null,
          lazy: false,
        ),
      ],
      child: child,
    );
  }

  Future<void> _preCacheEmojis(EmojiData data) async {
    svg.cache.maximumSize = 400;
    for (var category in data.categories) {
      for (var emoji in category.emojis) {
        final icon = AssetBytesLoader(EmojiData.svgPath(emoji));
        await svg.cache.putIfAbsent(
          icon.cacheKey(null),
          () => icon.loadBytes(null),
        );
      }
    }
  }
}
