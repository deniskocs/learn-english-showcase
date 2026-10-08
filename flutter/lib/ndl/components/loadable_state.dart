/// Типы состояний загрузки
enum LoadableStateType {
  loading,
  data,
  nodata,
  error,
}

/// Универсальный класс для состояний загрузки
class LoadableState<TData> {
  /// Тип состояния
  final LoadableStateType type;

  /// Данные состояния (типизированные)
  final TData? data;

  /// Сообщение об ошибке (если состояние error)
  final String? errorMessage;

  LoadableState({
    required this.type,
    this.data,
    this.errorMessage,
  });

  factory LoadableState.loading() {
    return LoadableState<TData>(type: LoadableStateType.loading);
  }

  factory LoadableState.data(TData data) {
    return LoadableState<TData>(
      type: LoadableStateType.data,
      data: data,
    );
  }

  factory LoadableState.nodata() {
    return LoadableState<TData>(type: LoadableStateType.nodata);
  }

  factory LoadableState.error(String errorMessage) {
    return LoadableState<TData>(
      type: LoadableStateType.error,
      errorMessage: errorMessage,
    );
  }
}
