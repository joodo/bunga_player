import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

late final BungaLogger logger;
Future<void> initializeLogger() async {
  final dir = await getApplicationSupportDirectory();
  final logPath = '${dir.path}/logs/';
  logger = BungaLogger(logPath);

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details.exceptionAsString(), stack: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e(error.toString(), stack: stack);
    return true;
  };
}

class BungaLogger {
  static final streamOutput = StreamOutput();
  final Stream<List<String>> stream = streamOutput.stream.asBroadcastStream();

  final consoleLogger = Logger(
    output: MultiOutput([streamOutput, ConsoleOutput()]),
    printer: SimplePrinter(colors: false, printTime: true),
    filter: ProductionFilter(),
    level: Level.info,
  );

  final String dirPath;
  String get latestPath => '${dirPath}latest.log';
  late final Logger fileLogger = Logger(
    output: AdvancedFileOutput(
      path: dirPath,
      maxFileSizeKB: 512,
      maxRotatedFilesCount: 3,
    ),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      noBoxingByDefault: true,
    ),
    filter: ProductionFilter(),
    level: Level.info,
  );

  BungaLogger(this.dirPath);

  void i(dynamic message) {
    consoleLogger.i(message);
    fileLogger.i(message);
  }

  void w(dynamic message) {
    consoleLogger.w(message);
    fileLogger.w(message);
  }

  void e(dynamic message, {StackTrace? stack}) {
    consoleLogger.e(message, stackTrace: stack);
    fileLogger.e(message, stackTrace: stack);
  }
}
