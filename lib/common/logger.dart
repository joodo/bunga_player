import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final loggerStream = StreamOutput();

final logger = Logger(
  output: loggerStream,
  printer: SimplePrinter(),
  level: Level.info,
);

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _logs = List<String>.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: loggerStream.stream,
          builder: (context, snapshot) {
            if (snapshot.data != null) _logs.addAll(snapshot.data!);
            return Text(_logs.join('\n'));
          },
        ),
      ),
    );
  }
}
