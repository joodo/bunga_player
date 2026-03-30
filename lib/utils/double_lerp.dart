extension Lerp on double {
  int get toLevel => lerp(0, 100);
  int lerp(int min, int max) => (min + (max - min) * this).round();
}
