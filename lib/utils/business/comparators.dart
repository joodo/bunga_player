Comparator<T> compareBy<T, R extends Comparable>(
  R Function(T e) keyOf, [
  Comparator<R>? compare,
]) {
  final f = compare ?? (R a, R b) => a.compareTo(b);
  return (T a, T b) => f(keyOf(a), keyOf(b));
}
