part of 'nats_playground_cubit.dart';

@freezed
class NatsPlaygroundState with _$NatsPlaygroundState {
  const factory NatsPlaygroundState.initial({
    @Default(false) bool isConnected,
    @Default(false) bool isLoading,
    @Default("Not connected") String connectionStatus,
    
    // Publish section
    @Default("No message published") String publishStatus,
    
    // Request section
    @Default("No request sent") String requestResponse,
    @Default("") String requestResponseTime,
    
    // Responder section
    @Default("Responder not active") String responderStatus,
    @Default(false) bool isResponderActive,
    @Default("No requests yet") String lastRequestReceived,
    @Default("") String lastRequestTime,
    @Default("responder-123") String responderID,
    
    // Subscriber section
    @Default("Subscriber not active") String subscriberStatus,
    @Default(false) bool isSubscriberActive,
    @Default("No messages yet") String lastPublishMsgReceived,
    @Default("") String lastPublishMsgTime,
    @Default("subscriber-123") String subscriberID,
    
    // Key-Value section
    @Default("No KV operations performed") String kvStatus,
    @Default("") String kvLastOperationTime,
  }) = _Initial;
}
