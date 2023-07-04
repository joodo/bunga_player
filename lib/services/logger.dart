import 'package:logger/logger.dart';

final loggerStream = StreamOutput();

final logger = Logger(
  output: loggerStream,
  printer: SimplePrinter(colors: false),
  filter: ProductionFilter(),
  level: Level.info,
);
