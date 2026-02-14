import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

late final BungaLogger logger;
Future<void> initializeLogger() async {
  final dir = await getApplicationSupportDirectory();
  final logPath = '${dir.path}/logs/';
  logger = BungaLogger(logPath);

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details.toString());
  };
}

class BungaLogger extends Logger {
  static final streamOutput = StreamOutput();

  BungaLogger(this.dirPath)
    : super(
        output: MultiOutput([
          streamOutput,
          AdvancedFileOutput(
            path: dirPath,
            maxFileSizeKB: 512,
            maxRotatedFilesCount: 3,
          ),
          ConsoleOutput(),
        ]),
        printer: SimplePrinter(colors: false),
        filter: ProductionFilter(),
        level: Level.info,
      );

  final String dirPath;
  String get latestPath => '${dirPath}latest.log';
  final Stream<List<String>> stream = streamOutput.stream.asBroadcastStream();
}
