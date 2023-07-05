import 'dart:async';

import 'package:file_selector/file_selector.dart';

Future<XFile?> openLocalVideoDialog() async {
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

  return openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
}
