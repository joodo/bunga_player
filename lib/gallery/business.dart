import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/utils/typedef.dart';

import 'models/models.dart';

typedef LinkerSearchResult = ({Linker info, Iterable<MediaSummary> results});

Future<Map<String, LinkerSearchResult>> search(
  BuildContext context,
  String keyword,
) async {
  final response =
      Actions.invoke(
            context,
            DoServerRequestIntent(
              reqFunc: (origin, headers) {
                final url = origin.replace(
                  pathSegments: ['api', 'gallery', 'search', ''],
                  queryParameters: {'keyword': keyword},
                );
                return http.get(url, headers: headers);
              },
            ),
          )
          as Future<JsonMap>;
  final json = await response;

  return json.map(
    (key, value) => MapEntry(key, (
      info: Linker.fromJson(value['info']),
      results: (value['results'] as List).map((e) => MediaSummary.fromJson(e)),
    )),
  );
}

final _detailCache = <(String linkerId, String key), AsyncCache<Media>>{};

Future<Media> detail(BuildContext context, String linkerId, String key) async {
  final cache = _detailCache.putIfAbsent((
    linkerId,
    key,
  ), () => AsyncCache<Media>(const Duration(minutes: 5)));

  return cache.fetch(() async {
    final response =
        Actions.invoke(
              context,
              DoServerRequestIntent(
                reqFunc: (origin, headers) {
                  final url = origin.replace(
                    pathSegments: ['api', 'gallery', key, ''],
                    queryParameters: {'linker': linkerId},
                  );
                  return http.get(url, headers: headers);
                },
              ),
            )
            as Future<JsonMap>;
    final data = await response;
    return Media.fromJson(data);
  });
}

Future<Iterable<Source>> sources(
  BuildContext context,
  String linkerId,
  String mediaKey,
  String epId,
) async {
  final response =
      Actions.invoke(
            context,
            DoServerRequestIntent(
              reqFunc: (origin, headers) {
                final url = origin.replace(
                  pathSegments: ['api', 'gallery', mediaKey, 'sources', ''],
                  queryParameters: {'linker': linkerId, 'ep': epId},
                );
                return http.get(url, headers: headers);
              },
            ),
          )
          as Future<JsonMap>;
  final json = await response;
  final s = json['sources'] as List;

  return s.map((e) => Source.fromJson(e));
}

Uri createUrl(String linkerId, String mediaKey, String epId) =>
    Uri(scheme: 'gallery', host: linkerId, pathSegments: [mediaKey, epId]);

typedef SummaryWithLinkerId = ({MediaSummary item, String linkerId});

class HistoryNotifier extends ChangeNotifier
    implements ValueListenable<List<SummaryWithLinkerId>> {
  static const prefKey = 'gallery_history';
  static const maxCount = 10;

  @override
  late final List<SummaryWithLinkerId> value;

  HistoryNotifier() {
    _load();
  }

  @override
  void dispose() {
    _save();
    super.dispose();
  }

  void update({required String linkerId, required MediaSummary item}) {
    value
      ..removeWhere((element) => element.item.key == item.key)
      ..insert(0, (item: item, linkerId: linkerId));

    if (value.length > maxCount) value.removeLast();

    notifyListeners();
  }

  bool remove({required String linkerId, required String itemKey}) {
    bool test(SummaryWithLinkerId e) =>
        e.item.key == itemKey && e.linkerId == linkerId;
    if (!value.any(test)) return false;

    value.removeWhere(test);
    notifyListeners();
    return true;
  }

  void _load() {
    final list = getIt<Preferences>().get<List<String>>(prefKey);
    if (list == null) {
      value = [];
    }

    try {
      value = list!.map((e) {
        final json = jsonDecode(e);
        return (
          item: MediaSummary.fromJson(json['item']),
          linkerId: json['linker_id'] as String,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      logger.w('Load gallery history failed: $e');
    }
  }

  void _save() {
    getIt<Preferences>().set(
      prefKey,
      value
          .map(
            (e) =>
                jsonEncode({'item': e.item.toJson(), 'linker_id': e.linkerId}),
          )
          .toList(),
    );
  }
}
