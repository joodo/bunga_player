import 'package:collection/collection.dart';

extension ContainsWhere<T> on Iterable<T> {
  bool containsWhere(bool Function(T element) test) {
    return firstWhereOrNull(test) != null;
  }
}
