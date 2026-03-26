import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';

class Watchers extends Iterable<User> {
  final Iterable<User> iterable;
  const Watchers(this.iterable);

  @override
  Iterator<User> get iterator => iterable.iterator;

  @override
  String toString() => jsonEncode(map((e) => e.toJson()).toList());
}

class WatchersNotifier extends ChangeNotifier
    implements ValueListenable<Watchers> {
  final User myself;
  WatchersNotifier({required this.myself}) {
    upsertInfo(myself);
  }

  final Map<String, User> _infos = {};

  void setInfos(Iterable<User> users) {
    _infos.clear();
    _infos[myself.id] = myself;
    for (var u in users) {
      _infos[u.id] = u;
    }
    notifyListeners();
  }

  bool upsertInfo(User user) {
    if (_infos[user.id] != user) {
      _infos[user.id] = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  final List<String> _ids = [];

  void setIds(List<String> ids) {
    if (listEquals(ids, _ids)) return;

    _ids.clear();
    _ids.addAll(ids);
    notifyListeners();
  }

  bool removeId(String id) {
    if (_ids.remove(id)) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  @override
  Watchers get value =>
      Watchers(_infos.values.where((u) => _ids.contains(u.id)));
}

extension ChatProvidersExtension on Widget {
  Widget chatProviders({required WatchersNotifier watchersNotifier}) =>
      MultiProvider(
        providers: [ValueListenableProvider.value(value: watchersNotifier)],
        child: this,
      );
}
