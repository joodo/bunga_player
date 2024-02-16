import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/models/chat/channel_data.dart';
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
  late final String hash;
  late final String title;
  late final VideoSources sources; // DURL | Dash

  late final String? image;
  late final String? path;

  static final Map<String, VideoEntry Function(ChannelData hash)> _factoryMap =
      {
    AListEntry.hashPrefix: AListEntry.fromChannelData,
    BiliBungumiEntry.hashPrefix: BiliBungumiEntry.fromChannelData,
    BiliVideoEntry.hashPrefix: BiliVideoEntry.fromChannelData,
  };

  VideoEntry();

  factory VideoEntry.fromChannelData(ChannelData channelData) {
    final prefix = channelData.videoHash.split('-').first;
    if (!_factoryMap.containsKey(prefix)) {
      throw FormatException('RemoteVideoEntry: unknown hash prefix: $prefix');
    }

    return _factoryMap[prefix]!(channelData);
  }

  bool get isFetched;
  Future<void> fetch();
}
