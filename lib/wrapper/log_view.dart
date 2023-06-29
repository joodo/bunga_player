import 'package:bunga_player/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogView extends StatefulWidget {
  final Widget child;
  const LogView({super.key, required this.child});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _logs = List<String>.empty(growable: true);
  bool _showLog = false;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.f12) {
          setState(() {
            _showLog = !_showLog;
          });
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Visibility(
            maintainState: true,
            visible: _showLog,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder(
                  stream: loggerStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      _logs.addAll(snapshot.data!);
                      debugPrint(snapshot.data!.join('\n'));
                    }
                    return Text(
                      _logs.join('\n'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
