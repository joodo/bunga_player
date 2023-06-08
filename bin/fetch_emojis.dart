// ignore_for_file: avoid_print

import 'dart:io';

import 'package:bunga_player/constants/constants.dart';
import 'package:http/http.dart';

void main() async {
  String? previousCode;
  for (var rune in Popmoji.emojis.runes) {
    var svgCode = rune.toRadixString(16);
    final String animeCode;
    if (svgCode.length < 5) {
      if (previousCode == null) {
        previousCode = svgCode;
        continue;
      } else {
        animeCode = '${previousCode}_$svgCode';
        svgCode = previousCode;
        previousCode = null;
      }
    } else {
      animeCode = svgCode;
    }

    print('$animeCode:');
    final svgFile = File('assets/images/emojis/u$svgCode.svg');
    if (await svgFile.exists()) {
      print('  Svg file exists.');
    } else {
      print('  Downloading svg file...');
      final response = await get(Uri.parse(
          'https://raw.githubusercontent.com/adobe-fonts/noto-emoji-svg/main/svg/u$svgCode.svg'));
      await svgFile.writeAsBytes(response.bodyBytes);
    }
    final lottieFile = File('assets/images/emojis/u$animeCode.json');
    if (await lottieFile.exists()) {
      print('  Lottie file exists.');
    } else {
      print('  Downloading lottie file...');
      final response = await get(Uri.parse(
          'https://fonts.gstatic.com/s/e/notoemoji/latest/$animeCode/lottie.json'));
      await lottieFile.writeAsBytes(response.bodyBytes);
    }
  }
}
