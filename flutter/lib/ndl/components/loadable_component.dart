import 'dart:async';
import 'package:flutter/material.dart';
import 'loadable_state.dart';

class LoadableComponent<TData, TState extends LoadableState<TData>> extends StatefulWidget {
  final Stream<TState> stateStream;
  final Widget Function(BuildContext context, TData data) dataContentBuilder;
  final Future<void> Function() loadFunction;

  const LoadableComponent({
    super.key,
    required this.stateStream,
    required this.dataContentBuilder,
    required this.loadFunction,
  });

  @override
  State<LoadableComponent<TData, TState>> createState() => _LoadableComponentState<TData, TState>();
}

class _LoadableComponentState<TData, TState extends LoadableState<TData>> extends State<LoadableComponent<TData, TState>> {
  @override
  void initState() {
    super.initState();
    widget.loadFunction();
  }

  Widget buildContent() {
    return StreamBuilder<TState>(
      stream: widget.stateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final state = snapshot.data!;

        switch (state.type) {
          case LoadableStateType.loading:
            return const Center(child: CircularProgressIndicator());

          case LoadableStateType.error:
            return Center(
              child: Text('Ошибка: ${state.errorMessage ?? "Неизвестная ошибка"}'),
            );

          case LoadableStateType.nodata:
            return const Center(child: Text('Нет данных'));

          case LoadableStateType.data:
            final data = state.data;
            if (data == null) {
              return const Center(child: Text('Нет данных'));
            }
            return widget.dataContentBuilder(context, data);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildContent();
  }
}
