import 'dart:async';

import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:file_selector/file_selector.dart';
import 'package:window_manager/window_manager.dart';

class LocalVideoChannelData {
  final String name;
  final String hash;
  LocalVideoChannelData({required this.name, required this.hash});
}

Future<LocalVideoChannelData> openLocalVideo() async {
  const typeGroup = XTypeGroup(
    label: 'videos',
    extensions: <String>[
      'webm',
      'mkv',
      'flv',
      'vob',
      'ogv',
      'ogg',
      'rrc',
      'gifv',
      'mpeg',
      'rm',
      'qt',
      'mng',
      'mov',
      'avi',
      'wmv',
      'yuv',
      'asf',
      'amv',
      'mp4',
      'm4p',
      'm4v',
      'mpg',
      'mp2',
      'mpe',
      'mpv',
      'm4v',
      'svi',
      '3gp',
      '3g2',
      'mxf',
      'roq',
      'nsv',
      'flv',
      'f4v',
      'f4p',
      'f4a',
      'f4b',
      'mod',
      'rm',
      'rmvb',
    ],
  );
  final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (file == null) throw NoFileSelectedException();

  VideoPlayer().stop();

  UINotifiers().hintText.value = '正在收拾客厅……';
  await VideoPlayer().loadLocalVideo(file.path);
  final hash = VideoPlayer().videoHashNotifier.value!;

  windowManager.setTitle(file.name);

  return LocalVideoChannelData(name: file.name, hash: hash);
}
