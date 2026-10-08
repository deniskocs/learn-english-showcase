import 'trained_pair.dart';

enum TrainedWordsStateType {
  loading,
  data,
  nodata,
  error,
}

class TrainedWordsState {
  final TrainedWordsStateType type;
  final List<TrainedPair>? data;
  final String? errorMessage;

  TrainedWordsState({
    required this.type,
    this.data,
    this.errorMessage,
  });

  factory TrainedWordsState.loading() {
    return TrainedWordsState(type: TrainedWordsStateType.loading);
  }

  factory TrainedWordsState.data(List<TrainedPair> data) {
    return TrainedWordsState(
      type: TrainedWordsStateType.data,
      data: data,
    );
  }

  factory TrainedWordsState.nodata() {
    return TrainedWordsState(type: TrainedWordsStateType.nodata);
  }

  factory TrainedWordsState.error(String errorMessage) {
    return TrainedWordsState(
      type: TrainedWordsStateType.error,
      errorMessage: errorMessage,
    );
  }

  List<TrainedPair> get words => data ?? [];
}
