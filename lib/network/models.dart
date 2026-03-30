import 'package:flutter/foundation.dart';

@immutable
class RequestProgress {
  final int total;
  final int current;
  const RequestProgress({required this.total, required this.current});

  double? get percent => total == 0 ? null : current / total;

  @override
  String toString() => 'RequestProgress $current/$total';
}
