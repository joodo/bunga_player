import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/bunga_server/actions.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/utils/extensions/file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path_tool;

import 'package:bunga_player/alist/actions.dart';
import 'package:bunga_player/alist/extensions.dart';
import 'package:bunga_player/alist/models.dart';
import 'package:bunga_player/bilibili/extensions.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/extensions/string.dart';
import 'package:bunga_player/utils/models/file_extensions.dart';

import 'models/play_payload.dart';
import 'models/video_record.dart';

typedef DirInfo = ({
  String name,
  int current,
  List<
      ({
        String name,
        Uri url,
        String? thumb,
      })> info,
});

class PlayPayloadParser {
  final BuildContext context;
  PlayPayloadParser(this.context);

  Future<PlayPayload> parse({Uri? url, VideoRecord? record}) async {
    if (record != null) {
      if (url != null) logger.w('"record" provided, url will not work.');
    } else if (url != null) {
      final record = await _parseUrl(url);
      return parse(record: record);
    } else {
      throw ArgumentError.notNull('url or record');
    }
    final parser = _createParser(context, record.source);
    return parser.parseVideoRecord(record);
  }

  Future<DirInfo?> dirInfo(VideoRecord record, {bool refresh = false}) {
    final parser = _createParser(context, record.source);
    return parser.fetchDirInfo(record, refresh: refresh);
  }

  _Parser _createParser(BuildContext context, String recordSource) =>
      switch (recordSource) {
        _LocalFileParser.recordSource => _LocalFileParser(),
        _AListParser.recordSource => _AListParser(context),
        _HttpParser.recordSource => _HttpParser(context),
        _BiliVideoParser.recordSource => _BiliVideoParser(context),
        _BiliBangumiParser.recordSource => _BiliBangumiParser(context),
        String() => throw TypeError(),
      };

  Future<VideoRecord> _parseUrl(Uri url) {
    if (!context.mounted) throw StateError('Context unmounted.');
    final parser = switch (url.scheme) {
      'file' => _LocalFileParser().parseUrl,
      'alist' => _AListParser(context).parseUrl,
      'http' || 'https' => _HttpParser(context).parseUrl,
      'history' => _parseHistoryUrl,
      String() => throw TypeError(),
    };
    return parser(url);
  }

  Future<VideoRecord> _parseHistoryUrl(Uri url) {
    assert(url.scheme == 'history');

    final recordId = url.pathSegments.first;
    final history = context.read<History>().value;
    return Future.value(history[recordId]!.videoRecord);
  }
}

abstract class _Parser {
  Future<VideoRecord> parseUrl(Uri url);
  Future<PlayPayload> parseVideoRecord(VideoRecord record);
  Future<DirInfo?> fetchDirInfo(VideoRecord record, {bool refresh = false});
}

class _LocalFileParser implements _Parser {
  static const recordSource = 'local';

  @override
  Future<VideoRecord> parseUrl(Uri url) async {
    final path = url.toFilePath();
    final file = File(path);

    final crcString = await file.crcString();

    final name = path_tool.basenameWithoutExtension(path);
    return VideoRecord(
      id: '$recordSource-$crcString',
      title: name,
      source: recordSource,
      path: path,
    );
  }

  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) {
    assert(record.source == recordSource);
    return Future.value(PlayPayload(
      record: record,
      sources: VideoSources.single(record.path),
    ));
  }

  @override
  Future<DirInfo?> fetchDirInfo(VideoRecord record, {bool refresh = false}) {
    assert(record.source == recordSource);

    final file = File(record.path);
    final dir = file.parent;
    final files = dir.listSync();

    final info = files
        .where((entry) => videoFileExtensions.contains(path_tool
            .extension(entry.path)
            .replaceFirst('.', '')
            .toLowerCase()))
        .map((entry) {
      final filename = path_tool.basename(entry.path);
      return (
        name: filename,
        url: Uri.file(entry.path),
        thumb: null,
      );
    }).sorted((a, b) => compareNatural(a.name, b.name));

    final filename = path_tool.basename(record.path);
    final current = info.indexWhere((e) => e.name == filename);

    return Future.value((
      name: path_tool.basename(dir.path),
      current: current,
      info: info,
    ));
  }
}

class _AListParser implements _Parser {
  static const recordSource = 'alist';

  static const _baiduHeaders = {'User-Agent': 'pan.baidu.com'};

  // Cache path - dirInfo
  static final _infoResponseCache = <String, List<AListFileDetail>>{};

  final BuildContext context;
  _AListParser(this.context);

  @override
  Future<VideoRecord> parseUrl(Uri url) {
    final path = Uri.decodeComponent(url.path);

    const encode = Uri.encodeComponent;
    final channelId = context.read<BungaClientInfo>().channel.id;
    final host = context.read<BungaHostAddress>().uri;
    final thumbUrl = host.resolve(
        '/api/channels/${encode(channelId)}/alist-thumbnail?path=${encode(path)}');

    // Record
    final name = path_tool.basenameWithoutExtension(path);

    return Future.value(VideoRecord(
      id: path.asPathToAListId(),
      title: name,
      source: recordSource,
      thumbUrl: thumbUrl.toString(),
      path: path,
    ));
  }

  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) async {
    assert(record.source == recordSource);

    final act = Actions.invoke(context, GetIntent(record.path))
        as Future<AListFileDetail>;
    final info = await act;
    return PlayPayload(
      record: record,
      sources: VideoSources.single(
        info.rawUrl!,
        requestHeaders: _baiduHeaders,
      ),
    );
  }

  @override
  Future<DirInfo?> fetchDirInfo(
    VideoRecord record, {
    bool refresh = false,
  }) async {
    assert(record.source == recordSource);

    final dirPath = path_tool.dirname(record.path);
    var infos = _infoResponseCache[dirPath];

    if (refresh || infos == null) {
      final act = Actions.invoke(context, ListIntent(dirPath, refresh: true))
          as Future<List<AListFileDetail>>;
      infos = await act;
    }

    final dirName = path_tool.basename(dirPath);
    final recordFilename = path_tool.basename(record.path);

    final info = infos
        .where((entry) => entry.type == AListFileType.video)
        .map((entry) => (
              name: entry.name,
              url: Uri(
                scheme: 'alist',
                path: path_tool.join(dirPath, entry.name),
              ),
              thumb: entry.thumb,
            ))
        .sorted((a, b) => compareNatural(a.name, b.name));

    final current = info.indexWhere((e) => e.name == recordFilename);
    return (
      name: dirName,
      info: info,
      current: current,
    );
  }
}

class _HttpParser implements _Parser {
  final BuildContext context;
  _HttpParser(this.context);

  static const recordSource = 'link';

  @override
  Future<VideoRecord> parseUrl(Uri url) async {
    if (url.host.endsWith('b23.tv') || url.host.endsWith('bilibili.com')) {
      return _BiliParser(context).parseUrl(url);
    }

    final response = await http.head(url);
    final contentType = response.headers['content-type'];
    if (contentType == null ||
        contentType != 'application/vnd.apple.mpegurl' &&
            contentType.startsWith('video')) {
      throw Exception(
          'fetch record failed: unknown content-type "$contentType"');
    }

    return VideoRecord(
      id: '$recordSource-${url.toString().hashStr}',
      title: url.pathSegments.last,
      source: recordSource,
      path: url.toString(),
    );
  }

  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) {
    assert(record.source == recordSource);
    return Future.value(PlayPayload(
      record: record,
      sources: VideoSources.single(record.path),
    ));
  }

  @override
  Future<DirInfo?> fetchDirInfo(VideoRecord record, {bool refresh = false}) {
    assert(record.source == recordSource);
    return Future.value(null);
  }
}

class _BiliParser implements _Parser {
  static const _biliHeaders = {
    'Referer': 'https://www.bilibili.com/',
    'User-Agent': 'Mozilla/5.0',
  };

  final BuildContext context;
  _BiliParser(this.context);

  late final biliToken = context.read<BungaClientInfo?>()?.bilibili;
  late final biliHeaders = biliToken == null
      ? null
      : {
          'Cookie': 'SESSDATA=${biliToken!.sess}',
          'Referer': 'https://www.bilibili.com',
        };

  @override
  Future<VideoRecord> parseUrl(Uri url) async {
    if (url.host.endsWith('b23.tv')) {
      final req = http.Request('Get', url)..followRedirects = false;
      final baseClient = http.Client();
      final response = await baseClient.send(req);
      final redirectUri = Uri.parse(response.headers['location']!);
      return parseUrl(redirectUri);
    }

    switch (url.pathSegments[0]) {
      case 'video':
        return _BiliVideoParser(context).parseUrl(url);
      case 'bangumi':
        return _BiliBangumiParser(context).parseUrl(url);
      default:
        throw Exception('Bilibili: unknown bilibili url: $url');
    }
  }

  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) =>
      throw UnimplementedError();

  @override
  Future<DirInfo?> fetchDirInfo(VideoRecord record, {bool refresh = false}) =>
      throw UnimplementedError();

  VideoSources parseVideoSourceData(dynamic data) {
    if (data['dash'] != null) {
      final dashData = data['dash'];

      final videoUrls = dashData['video'][0];
      final audioUrls = dashData['audio'][0];
      return VideoSources(
        videos: [
          videoUrls['base_url'],
          ...videoUrls['backup_url'] ?? [],
        ],
        audios: [
          audioUrls['base_url'],
          ...audioUrls['backup_url'] ?? [],
        ],
        requestHeaders: _biliHeaders,
      );
    } else if (data['durl'] != null) {
      final durlData = data['durl'][0];
      return VideoSources(
        videos: [
          durlData['url'],
          ...durlData['backup_url'] ?? [],
        ],
        requestHeaders: _biliHeaders,
      );
    } else {
      throw Exception('Failed to parse bili response data: $data');
    }
  }
}

class _BiliVideoParser extends _BiliParser {
  static const recordSource = 'bilivideo';

  // Cache bvid - data
  static final _infoResponseCache = <String, dynamic>{};

  _BiliVideoParser(super.context);

  // See https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/info.md
  @override
  Future<VideoRecord> parseUrl(Uri url) async {
    final regex = RegExp(r'\/BV(?<bvid>[A-Za-z0-9]*)\/?');
    final match = regex.firstMatch(url.path);
    if (match == null) {
      throw Exception('fetch record failed: No bv found in url');
    }
    final bvid = match.namedGroup('bvid')!;

    final p = int.parse(url.queryParameters['p'] ?? '1');

    // fetch video info
    final isHD = biliToken != null;
    if (!isHD) getIt<Toast>().show('无法获取高清视频');

    final query = {'bvid': bvid}.asBiliQueryEncWbi(biliToken?.mixinKey);
    final response = await http.get(
      Uri.parse('https://api.bilibili.com/x/web-interface/wbi/view?$query'),
      headers: biliHeaders,
    );
    final json = jsonDecode(response.body);
    if (json['code'] != 0) {
      throw Exception({
        'message': 'Cannot get bili video info',
        'detail': response.body,
      });
    }
    final responseData = json['data'];

    // Update cache
    _infoResponseCache[bvid] = responseData;

    // deal with data
    final thumbUrl = responseData['pic'];
    final List pages = responseData['pages'];
    final totalP = pages.length;
    final title = totalP > 1
        ? '${responseData['title']} [$p/$totalP]'
        : responseData['title'];
    final cid = pages[p - 1]['cid'].toString();

    return VideoRecord(
      id: '$recordSource-$bvid-$p',
      title: title,
      source: recordSource,
      thumbUrl: thumbUrl,
      path: '$bvid/$p/$cid',
    );
  }

  // See https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/videostream_url.md
  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) async {
    assert(record.source == recordSource);

    final [bvid, p, cid] = record.path.split('/');

    final query = {
      'bvid': bvid,
      'cid': cid,
      'fnval': '16',
    }.asBiliQueryEncWbi(biliToken?.mixinKey);
    final response = await http.get(
      Uri.parse('https://api.bilibili.com/x/player/playurl?$query'),
      headers: biliHeaders,
    );
    final json = jsonDecode(response.body);
    if (json['code'] != 0) {
      throw Exception({
        'message': 'Cannot get bili video url',
        'detail': response.body,
      });
    }

    final sources = parseVideoSourceData(json['data']);

    return PlayPayload(record: record, sources: sources);
  }

  @override
  Future<DirInfo?> fetchDirInfo(
    VideoRecord record, {
    bool refresh = false,
  }) async {
    assert(record.source == recordSource);

    final [bvid, pStr, _] = record.path.split('/');
    final p = int.parse(pStr);

    dynamic responseData = _infoResponseCache[bvid];
    if (refresh || responseData == null) {
      final query = {'bvid': bvid}.asBiliQueryEncWbi(biliToken?.mixinKey);
      final response = await http.get(
        Uri.parse('https://api.bilibili.com/x/web-interface/wbi/view?$query'),
        headers: biliHeaders,
      );
      final json = jsonDecode(response.body);
      if (json['code'] != 0) {
        throw Exception({
          'message': 'Cannot get bili video info',
          'detail': response.body,
        });
      }
      responseData = json['data'];
    }

    int current = 0;
    final info = (responseData['pages'] as List).indexed.map((e) {
      final (index, entry) = e;
      if (entry['page'] == p) current = index;
      return (
        name: entry['part'] as String,
        url: Uri.parse(
          'https://www.bilibili.com/video/BV$bvid/?p=${entry['page']}',
        ),
        thumb: entry['first_frame'] as String,
      );
    }).toList();

    return (
      name: responseData['title'] as String,
      info: info,
      current: current,
    );
  }
}

class _BiliBangumiParser extends _BiliParser {
  static const recordSource = 'bilibangumi';

  // Cache seasonId - data
  static final _infoResponseCache = <int, dynamic>{};

  _BiliBangumiParser(super.context);

  // See https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/bangumi/info.md
  @override
  Future<VideoRecord> parseUrl(Uri url) async {
    final idString = url.pathSegments[2];

    final epId = idString.startsWith('ep') ? idString.substring(2) : null;
    int? seasonId =
        idString.startsWith('ss') ? int.parse(idString.substring(2)) : null;

    if (epId == null && seasonId == null) {
      throw Exception('Failed to resolve bungami id: $idString');
    }

    final sess = biliToken?.sess;
    if (sess == null) {
      throw Exception('Fetch bungami failed: no sess.');
    }

    // fetch video info
    final query = epId != null ? 'ep_id=$epId' : 'season_id=$seasonId';
    final response = await http
        .get(Uri.parse('https://api.bilibili.com/pgc/view/web/season?$query'));
    final json = jsonDecode(utf8.decoder.convert(response.bodyBytes));
    if (json['code'] != 0) {
      throw Exception('Bilibili: cannot get video info: $query');
    }

    final responseData = json['result'];
    seasonId ??= responseData['season_id'] as int;
    _infoResponseCache[seasonId] = responseData;

    final episodes = responseData['episodes'] as List;
    final episode = epId == null
        ? episodes.first
        : episodes.firstWhereOrNull(
            (element) => element['ep_id'].toString() == epId,
          );
    if (episode == null) {
      throw Exception({
        'message': 'Cannot found episode info',
        'detail': response.body,
      });
    }

    return VideoRecord(
      id: '$recordSource-${episode['ep_id']}',
      title: episode['share_copy'],
      source: recordSource,
      thumbUrl: episode['cover'],
      path: '$seasonId/${episode['ep_id']}',
    );
  }

  // See https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/bangumi/videostream_url.md
  @override
  Future<PlayPayload> parseVideoRecord(VideoRecord record) async {
    assert(record.source == recordSource);

    final [season, ep] = record.path.split('/');

    final sess = biliToken?.sess;
    if (sess == null) {
      throw Exception('Fetch bungami failed: no sess.');
    }

    final response = await http.get(
      Uri.parse(
          'https://api.bilibili.com/pgc/player/web/playurl?ep_id=$ep&fnval=16'),
      headers: biliHeaders,
    );
    final json = jsonDecode(response.body);
    if (json['code'] != 0) {
      throw Exception({
        'message': 'Cannot get bili bungami url',
        'detail': response.body,
      });
    }

    final sources = parseVideoSourceData(json['result']);
    return PlayPayload(record: record, sources: sources);
  }

  @override
  Future<DirInfo?> fetchDirInfo(
    VideoRecord record, {
    bool refresh = false,
  }) async {
    assert(record.source == recordSource);

    final [season, ep] = record.path.split('/');

    dynamic responseData = _infoResponseCache[int.parse(season)];
    if (refresh || responseData == null) {
      final response = await http.get(
          Uri.parse('https://api.bilibili.com/pgc/view/web/season?ep_id=$ep'));
      final json = jsonDecode(utf8.decoder.convert(response.bodyBytes));
      if (json['code'] != 0) {
        throw Exception('Bilibili: cannot get bangumi info: $ep');
      }
      responseData = json['result'];
    }

    final episodes = responseData['episodes'] as List;
    final epId = int.parse(ep);

    int current = 0;
    final info = episodes.indexed.map((e) {
      final (index, entry) = e;
      if (entry['ep_id'] == epId) current = index;
      return (
        name: entry['show_title'] as String,
        url: Uri.parse(entry['share_url'] as String),
        thumb: entry['cover'] as String,
      );
    }).toList();

    return (
      name: responseData['season_title'] as String,
      info: info,
      current: current,
    );
  }
}
