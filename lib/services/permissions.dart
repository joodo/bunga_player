import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class Permissions {
  const Permissions();

  Future<void> requestVideoAndAudio() async {
    await _require(Permission.videos);
    await _require(Permission.audio);
  }

  Future<void> requestMicrophone() async {
    await _require(Permission.microphone);
  }

  Future<void> _require(Permission permission) async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isWindows)) return;

    if (await permission.isDenied || await permission.isPermanentlyDenied) {
      final state = await permission.request();
      if (!state.isGranted) {
        throw Exception('Permission: $permission required failed.');
      }
    }
  }
}
