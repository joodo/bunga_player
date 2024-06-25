import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:file_selector/file_selector.dart';

class LocalVideoEntryDialog {
  static const typeGroup = XTypeGroup(
    label: 'videos',
    uniformTypeIdentifiers: ['public.movie'],
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
    ],
  );

  Future<LocalVideoEntry?> show() async {
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) return null;

    return LocalVideoEntry.fromFile(file);
  }
}
