import 'package:logger/logger.dart';

final _logOutput = StreamOutput();

final loggerStream = _logOutput.stream.asBroadcastStream();

final logger = Logger(
  output: _logOutput,
  printer: SimplePrinter(colors: false),
  filter: ProductionFilter(),
  level: Level.info,
);
