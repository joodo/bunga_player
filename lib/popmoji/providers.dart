import 'dart:convert';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'models/data.dart';

enum EmojiListType { pinned, recent }

typedef EmojiIndex = ({EmojiListType list, int index});

class PopmojiBarItems extends ValueNotifier<
    ({
      List<String> pinned,
      List<String> recent,
    })> {
  PopmojiBarItems()
      : super((
          pinned: ["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"],
          recent: [],
        )) {
    bindPreference<List<String>>(
      preferences: getIt<Preferences>(),
      key: 'recent_popmojis',
      load: (pref) => (pinned: value.pinned, recent: pref),
      update: (value) => value.recent,
    );
    bindPreference<List<String>>(
      preferences: getIt<Preferences>(),
      key: 'pinned_popmojis',
      load: (pref) => (pinned: pref, recent: value.recent),
      update: (value) => value.pinned,
    );
  }

  void addRecent(String emoji) {
    if (value.pinned.contains(emoji)) return;
    if (value.recent.firstOrNull == emoji) return;

    value.recent.remove(emoji);
    value.recent.insert(0, emoji);
    notifyListeners();
  }

  void move(EmojiIndex from, EmojiIndex to) {
    if (from == to) return;

    if (from.list == to.list && from.index < to.index) {
      to = (
        list: to.list,
        index: to.index - 1,
      );
    }

    final removedValue = _getList(from.list).removeAt(from.index);
    _getList(to.list).insert(to.index, removedValue);
    notifyListeners();
  }

  List<String> _getList(EmojiListType type) {
    return type == EmojiListType.pinned ? value.pinned : value.recent;
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
  ChangeNotifierProvider(create: (context) => PopmojiBarItems()),
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
