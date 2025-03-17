part of 'nats_playground_cubit.dart';

@freezed
class NatsPlaygroundState with _$NatsPlaygroundState {
  const factory NatsPlaygroundState.initial({
    @Default(false) bool isConnected,
    @Default(false) bool isLoading,
  }) = _Initial;
}
