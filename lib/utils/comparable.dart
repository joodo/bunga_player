extension Clamp<T extends Comparable<T>> on T {
  T clamp(T min, T max) => compareTo(min) < 0
      ? min
      : compareTo(max) > 0
          ? max
          : this;
}

T max<T extends Comparable<T>>(T a, T b) => a.compareTo(b) > 0 ? a : b;
T min<T extends Comparable<T>>(T a, T b) => a.compareTo(b) < 0 ? a : b;
