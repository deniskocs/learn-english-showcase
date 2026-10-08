class ConfigService {
  List<Function> subscribers = <Function>[];

  Map<int, bool> selectedStages = <int, bool>{};

  ConfigService() {
    for (int i = 0; i < 10; i++) {
      selectedStages[i] = true;
    }
  }

  void addSubscriber(Function subscriber) {
    subscribers.add(subscriber);
  }

  void update() {
    for (var element in subscribers) {
      element();
    }
  }
}
