// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  const path = 'build/windows/x64/runner/Release/';
  const files = [
    'libagora_audio_beauty_extension.dll',
    'libagora_audio_beauty_extension.dll.lib',
    'libagora_clear_vision_extension.dll',
    'libagora_clear_vision_extension.dll.lib',
    'libagora_content_inspect_extension.dll',
    'libagora_content_inspect_extension.dll.lib',
    'libagora_pvc_extension.dll',
    'libagora_face_capture_extension.dll',
    'libagora_face_capture_extension.dll.lib',
    'libagora_face_detection_extension.dll',
    'libagora_face_detection_extension.dll.lib',
    'libagora_lip_sync_extension.dll',
    'libagora_lip_sync_extension.dll.lib',
    'libagora_screen_capture_extension.dll',
    'libagora_screen_capture_extension.dll.lib',
    'libagora_segmentation_extension.dll',
    'libagora_segmentation_extension.dll.lib',
    'libagora_spatial_audio_extension.dll',
    'libagora_spatial_audio_extension.dll.lib',
    'libagora_video_quality_analyzer_extension.dll',
    'libagora_video_quality_analyzer_extension.dll.lib',
    'libagora_video_encoder_extension.dll',
    'libagora_video_encoder_extension.dll.lib',
    'libagora_video_decoder_extension.dll',
    'libagora_video_decoder_extension.dll.lib',
    'libagora_video_av1_decoder_extension.dll',
    'libagora_video_av1_decoder_extension.dll.lib',
    'libagora_video_av1_encoder_extension.dll',
    'libagora_video_av1_encoder_extension.dll.lib',
    'video_enc.dll',
    'video_dec.dll',
    'libagora-wgc.dll',
  ];

  for (final filename in files) {
    File file = File('$path$filename');
    if (await file.exists()) {
      await file.delete();
      print('File deleted: $filename');
    } else {
      print('File does not exist: $filename');
    }
  }

  // Github action walkthrough
  // See https://github.com/actions/runner-images/issues/10004
  Directory('windows/gb_action_walkthrough').listSync().forEach((element) {
    if (element is File) {
      final newFilePath = '$path${element.uri.pathSegments.last}';
      element.copySync(newFilePath);
      print('File copyed: ${element.path} -> $newFilePath');
    }
  });
}
