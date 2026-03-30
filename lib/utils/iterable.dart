extension Alternate<T> on Iterable<T> {
  Iterable<T> alternateWith(T separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1);
  }
}
