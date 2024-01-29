import 'package:logger/logger.dart';

final logger = BungaLogger(StreamOutput());

class BungaLogger extends Logger {
  BungaLogger(StreamOutput streamOutput)
      : _streamOutput = streamOutput,
        super(
          output: MultiOutput([streamOutput, ConsoleOutput()]),
          printer: SimplePrinter(colors: false),
          filter: ProductionFilter(),
          level: Level.info,
        );

  final StreamOutput _streamOutput;
  late final Stream<List<String>> stream =
      _streamOutput.stream.asBroadcastStream();
}
