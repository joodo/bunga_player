// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:yaml/yaml.dart';

void main() async {
  if (Platform.isMacOS) {
    macosDeploy();
  } else if (Platform.isWindows) {
    windowsDeploy();
  }
}

void macosDeploy() async {
  print('Generating dmg file...');
  try {
    await Process.run(
      'mv',
      [
        'build/macos/Build/Products/Release/bunga_player.app',
        'build/macos/Build/Products/Release/Bunga Player.app',
      ],
    );

    final version = await getVersion();
    final targetName =
        'build/macos/Build/Products/Release/bunga_player_installer_${version.replaceAll('.', '_')}_macos.dmg';
    await Process.run('rm', [targetName]);
    await Process.run(
      'appdmg',
      [
        'macos/deploy/deploy.json',
        targetName,
      ],
    );

    await Process.run('open', ['build/macos/Build/Products/Release/']);
  } on ProcessException {
    print(
        'Error: please install "appdmg" first:\n\nnpm install --global appdmg\n');
  }
}

void windowsDeploy() async {
  try {
    final process = await Process.start('ISCC.exe', [
      'windows/installer/script.iss',
    ]);
    process.stdout.transform(utf8.decoder).forEach(print);
    await process.exitCode;

    final outputPath = Directory('.\\windows\\installer\\Output').absolute.path;
    await Process.run(
      'explorer',
      [outputPath],
    );
  } on ProcessException {
    print(
        'Error: please set inno setup install path to environment variable "PATH" first.');
  }
}

Future<String> getVersion() async {
  File f = File('pubspec.yaml');
  Map yaml = loadYaml(await f.readAsString());
  return yaml['version'];
}
