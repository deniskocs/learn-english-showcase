import 'package:learn_english/utils/random_generator.dart';

class Utils {
  static List<T> mix<T>(List<T> src) {
    var srcCopy = [...src];
    RandomGenerator.instance.reset();
    List<T> dst = <T>[];

    while (srcCopy.isNotEmpty) {
      var index = RandomGenerator.instance.nextInt() % srcCopy.length;
      var element = srcCopy.removeAt(index);
      dst.add(element);
    }

    return dst;
  }
}
