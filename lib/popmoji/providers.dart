import 'dart:convert';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'models/data.dart';

class RecentEmojis extends ValueNotifier<List<String>> {
  RecentEmojis()
      : super(["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"]) {
    bindPreference<List<String>>(
      preferences: getIt<Preferences>(),
      key: 'recent_popmojis',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

final popmojiProviders = MultiProvider(providers: [
  FutureProvider<EmojiData?>(
    create: (context) async {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/emojis/emojis.json');
      final data = EmojiData.fromJson(jsonDecode(jsonString));

      _cacheEmojis(data);

      return data;
    },
    initialData: null,
    lazy: false,
  ),
  ChangeNotifierProvider(create: (context) => RecentEmojis()),
]);

Future<void> _cacheEmojis(EmojiData data) async {
  for (var category in data.categories) {
    for (var emoji in category.emojis) {
      final icon = SvgAssetLoader(EmojiData.svgPath(emoji));
      await svg.cache
          .putIfAbsent(icon.cacheKey(null), () => icon.loadBytes(null));
    }
  }
}
