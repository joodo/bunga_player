import 'dart:io';

import 'package:innosetup/innosetup.dart';
import 'package:version/version.dart';
import 'package:yaml/yaml.dart';

void main() async {
  final version = await getVersion();

  InnoSetup(
    name: InnoSetupName(
      'bunga_player_installer_${version.replaceAll('.', '_')}_windows',
    ),
    app: InnoSetupApp(
      id: '{{059ED6DF-8FFF-4F1F-A617-AC5D812BE383}',
      name: 'Bunga Player',
      version: Version.parse(version),
      publisher: 'Joodo',
      executable: 'bunga_player.exe',
      urls: InnoSetupAppUrls(
        homeUrl: Uri.parse('https://github.com/joodo/bunga_player'),
        publisherUrl: Uri.parse('https://github.com/joodo/bunga_player'),
        supportUrl: Uri.parse('https://github.com/joodo/bunga_player'),
        updatesUrl: Uri.parse('https://github.com/joodo/bunga_player'),
      ),
      wizardStyle: InnoSetupWizardStyle.modern,
    ),
    files: InnoSetupFiles(
      executable: File('build/windows/x64/runner/Release/bunga_player.exe'),
      location: Directory('build/windows/x64/runner/Release'),
    ),
    location: InnoSetupInstallerDirectory(
      Directory('build/windows'),
    ),
    languages: [
      InnoSetupLanguages().english,
      InnoSetupLanguage.custom(
        'chinesesimplified',
        File('windows/installer/ChineseSimplified.isl').absolute,
      ),
    ],
    icon: InnoSetupIcon(
      File('windows/installer/installer.ico'),
    ),
    privileges: InnoSetupPrivileges(
      required: InnoSetupPrivilegeRequired.lowest,
      overrideByCommandline: true,
      overrideByDialog: true,
    ),
    compression: InnoSetupCompression.level(
      'lzma2',
      InnoSetupCompressionLevel.ultra64,
      solid: true,
    ),
    desktopIcon: true,
  ).make(dry: true);
}

Future<String> getVersion() async {
  File f = File('pubspec.yaml');
  Map yaml = loadYaml(await f.readAsString());
  return yaml['version'];
}
