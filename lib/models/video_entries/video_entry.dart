import 'dart:convert';
import 'dart:io';

import 'package:crclib/catalog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';

part 'local_video_entry.dart';
part 'a_list_entry.dart';
part 'bili_bungumi_entry.dart';
part 'bili_video_entry.dart';

class VideoSources {
  final List<String> video;
  final List<String>? audio;

  VideoSources({required this.video, this.audio});
}

sealed class VideoEntry {
  late final String title;
  late final String image;
  late final VideoSources sources; // DURL | Dash

  static final Map<String, VideoEntry Function(String hash)> fromHashMap = {
    AListEntry.hashPrefix: AListEntry.fromHash,
    BiliBungumiEntry.hashPrefix: BiliBungumiEntry.fromHash,
    BiliVideoEntry.hashPrefix: BiliVideoEntry.fromHash,
  };

  VideoEntry();

  bool get isFetched;
  Future<void> fetch();

  String get hash;
  factory VideoEntry.fromHash(String hash) {
    final prefix = hash.split('-').first;
    if (!fromHashMap.containsKey(prefix)) {
      throw FormatException('RemoteVideoEntry: unknown hash prefix: $prefix');
    }

    return fromHashMap[prefix]!(hash);
  }
}
