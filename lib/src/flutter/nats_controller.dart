import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_nats/src/rust/api/nats.dart' as nats_lib;

/// A controller for managing NATS connections and operations
class NatsController extends ChangeNotifier {
  /// Creates a new NATS controller with the specified configuration
  NatsController({required nats_lib.NatsConfig config}) {
    _config = config;
  }

  late nats_lib.NatsConfig _config;
  final String _clientId = const Uuid().v4();
  bool _isConnected = false;

  /// The unique client ID for this controller
  String get clientId => _clientId;

  /// The current NATS configuration
  nats_lib.NatsConfig get config => _config;
  String get endPoint => "nats://${config.host}:${config.port}";

  /// Whether this client is currently connected
  bool get isConnected => _isConnected;

  /// Update the configuration (only works if not connected)
  set config(nats_lib.NatsConfig value) {
    if (!_isConnected) {
      _config = value;
      notifyListeners();
    } else {
      debugPrint('Cannot change configuration while connected');
    }
  }

  /// Connect to the NATS server
  ///
  /// Optional callbacks can be provided for success or failure
  void connect({
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.connect(
      clientId: _clientId,
      config: _config,
      onSuccess: (value) {
        _isConnected = true;
        notifyListeners();
        if (onSuccess != null) onSuccess(value);
      },
      onFailure: (value) {
        _isConnected = false;
        notifyListeners();
        if (onFailure != null) onFailure(value);
      },
    );
  }

  /// Disconnect from the NATS server
  ///
  /// Optional callbacks can be provided for success or failure
  void disconnect({
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.disconnect(
      clientId: _clientId,
      onSuccess: (value) {
        _isConnected = false;
        notifyListeners();
        if (onSuccess != null) onSuccess(value);
      },
      onFailure: (value) {
        if (onFailure != null) onFailure(value);
      },
    );
  }

  /// Send a request to the NATS server and get the response as a Future
  ///
  /// [subject] - The subject to send the request to
  /// [payload] - The message payload as a string
  /// [timeoutMs] - Request timeout in milliseconds (default: 5000)
  Future<String> sendRequest({
    required String subject,
    required String payload,
    int timeoutMs = 5000,
  }) async {
    return nats_lib.sendRequest(
      clientId: _clientId,
      subject: subject,
      payload: payload,
      timeoutMs: BigInt.from(timeoutMs),
    );
  }

  /// Send a request to the NATS server with callbacks for handling the response
  ///
  /// [subject] - The subject to send the request to
  /// [payload] - The message payload as a string
  /// [timeoutMs] - Request timeout in milliseconds (default: 5000)
  /// [onSuccess] - Callback for successful response
  /// [onFailure] - Callback for request failure
  void sendRequestWithCallbacks({
    required String subject,
    required String payload,
    int timeoutMs = 5000,
    required ValueChanged<String> onSuccess,
    required ValueChanged<String> onFailure,
  }) {
    nats_lib.sendRequestWithCallbacks(
      clientId: _clientId,
      subject: subject,
      payload: payload,
      timeoutMs: BigInt.from(timeoutMs),
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }

  /// Publish a message to the specified subject
  ///
  /// [subject] - The subject to publish to
  /// [payload] - The message payload as a string
  /// [onSuccess] - Optional callback for successful publish
  /// [onFailure] - Optional callback for publish failure
  void publish({
    required String subject,
    required String payload,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.publish(
      clientId: _clientId,
      subject: subject,
      payload: payload,
      onSuccess: onSuccess ?? (_) {},
      onFailure: onFailure ?? (_) {},
    );
  }

  /// Set up a responder to handle requests on a specified subject
  ///
  /// [subject] - The subject to listen for requests on
  /// [responderId] - A unique identifier for this responder (defaults to a UUID)
  /// [processRequest] - Function that processes requests and returns responses
  /// [onSuccess] - Optional callback for successful setup
  /// [onError] - Optional callback for setup failure
  void setupResponder({
    required String subject,
    String? responderId,
    required Future<String> Function(String request) processRequest,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onError,
  }) {
    final id = responderId ?? const Uuid().v4();
    nats_lib.setupResponder(
      clientId: _clientId,
      subject: subject,
      responderId: id,
      processRequest: processRequest,
      onSuccess: onSuccess ?? (_) {},
      onError: onError ?? (_) {},
    );
  }

  /// Subscribe to a subject and receive messages via a callback
  ///
  /// [subject] - The subject to subscribe to (can include wildcards)
  /// [subscriptionId] - A unique identifier for this subscription (defaults to a UUID)
  /// [maxMessages] - Maximum number of messages to process (0 for unlimited)
  /// [onMessage] - Callback function called when a message is received
  /// [onSuccess] - Optional callback for successful subscription
  /// [onError] - Optional callback for subscription failure
  /// [onDone] - Optional callback for when subscription ends
  void subscribe({
    required String subject,
    String? subscriptionId,
    int maxMessages = 0,
    required void Function(String subject, String message) onMessage,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onError,
    VoidCallback? onDone,
  }) {
    final id = subscriptionId ?? const Uuid().v4();
    nats_lib.subscribe(
      clientId: _clientId,
      subject: subject,
      subscriptionId: id,
      maxMessages: maxMessages,
      onMessage: onMessage,
      onSuccess: onSuccess ?? (_) {},
      onError: onError ?? (_) {},
      onDone: onDone ?? () {},
    );
  }

  /// Unsubscribe from a subject
  ///
  /// [subscriptionId] - The ID of the subscription to cancel
  /// [onSuccess] - Optional callback for successful unsubscribe
  /// [onFailure] - Optional callback for unsubscribe failure
  void unsubscribe({
    required String subscriptionId,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.unsubscribe(
      clientId: _clientId,
      subscriptionId: subscriptionId,
      onSuccess: onSuccess ?? (_) {},
      onFailure: onFailure ?? (_) {},
    );
  }

  /// Get a list of active subscription IDs for this client
  Future<List<String>> listSubscriptions() async {
    return nats_lib.listSubscriptions(clientId: _clientId);
  }

  /// Store a value in the JetStream key-value store
  ///
  /// [bucketName] - The name of the KV bucket
  /// [key] - The key to store the value under
  /// [value] - The value to store
  /// [onSuccess] - Optional callback for successful storage
  /// [onFailure] - Optional callback for storage failure
  void kvPut({
    required String bucketName,
    required String key,
    required String value,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.kvPut(
      clientId: _clientId,
      bucketName: bucketName,
      key: key,
      value: value,
      onSuccess: onSuccess ?? (_) {},
      onFailure: onFailure ?? (_) {},
    );
  }

  /// Retrieve a value from the JetStream key-value store
  ///
  /// [bucketName] - The name of the KV bucket
  /// [key] - The key to retrieve
  /// [onSuccess] - Callback for successful retrieval with the value
  /// [onFailure] - Optional callback for retrieval failure
  void kvGet({
    required String bucketName,
    required String key,
    required ValueChanged<String> onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.kvGet(
      clientId: _clientId,
      bucketName: bucketName,
      key: key,
      onSuccess: onSuccess,
      onFailure: onFailure ?? (_) {},
    );
  }

  /// Delete a key from the JetStream key-value store
  ///
  /// [bucketName] - The name of the KV bucket
  /// [key] - The key to delete
  /// [onSuccess] - Optional callback for successful deletion
  /// [onFailure] - Optional callback for deletion failure
  void kvDelete({
    required String bucketName,
    required String key,
    ValueChanged<bool>? onSuccess,
    ValueChanged<String>? onFailure,
  }) {
    nats_lib.kvDelete(
      clientId: _clientId,
      bucketName: bucketName,
      key: key,
      onSuccess: onSuccess ?? (_) {},
      onFailure: onFailure ?? (_) {},
    );
  }

  @override
  void dispose() {
    // Ensure we disconnect when the controller is disposed
    if (_isConnected) {
      disconnect();
    }
    super.dispose();
  }
}
