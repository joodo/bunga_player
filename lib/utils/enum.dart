import 'package:collection/collection.dart';

T? enumFromString<T extends Enum>(Iterable<T> values, String value) {
  return values.firstWhereOrNull((e) => e.name == value);
}
