import 'dart:math';

class RandomGenerator {
  static final instance = RandomGenerator();

  int sid = 0;
  Random rng = Random();

  void reset() {
    sid = 0;
  }

  int nextInt() {
    return rng.nextInt(1000000);
    // sid += 654321;
    // return sid;
  }
}
