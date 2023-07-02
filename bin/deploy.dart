// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  if (Platform.isMacOS) {
    print('Generating dmg file...');
    try {
      print(
          'Please install "GraphicsMagick" to create icon:\n\nbrew install graphicsmagick imagemagick\n');
      var result = await Process.run(
        'create-dmg',
        [
          'build/macos/Build/Products/Release/bunga_player.app',
          'build/macos/Build/Products/Release/',
          '--overwrite',
        ],
      );
      if (result.exitCode != 0) {
        print('Error: ${result.stderr}');
      } else {
        Process.run(
            'open', ['build/macos/Build/Products/Release/bunga_player.app']);
      }
    } on ProcessException {
      print(
          'Error: please install "creaate-dmg" first:\n\nnpm install --global create-dmg\n');
    }
  }
}
