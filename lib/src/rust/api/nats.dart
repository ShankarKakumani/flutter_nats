// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.8.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `cleanup_client_subscriptions`, `cleanup_subscription`, `get_client`, `get_jetstream`, `get_kv_store_with_callback`, `get_next_message`, `get_or_create_kv_store`, `is_subscription_active`, `process_responder_requests`, `process_subscription_messages`, `subscription_exists`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `fmt`, `fmt`

/// Connects to a NATS server with the specified client ID and calls appropriate callback based on result.
Future<void> connect(
        {required String clientId,
        required NatsConfig config,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsConnect(
        clientId: clientId,
        config: config,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Disconnects a specific client from the NATS server.
Future<void> disconnect(
        {required String clientId,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsDisconnect(
        clientId: clientId, onSuccess: onSuccess, onFailure: onFailure);

/// Sends a request to NATS server using the specified client and returns the response.
Future<String> sendRequest(
        {required String clientId,
        required String subject,
        required String payload,
        required BigInt timeoutMs}) =>
    RustLib.instance.api.crateApiNatsSendRequest(
        clientId: clientId,
        subject: subject,
        payload: payload,
        timeoutMs: timeoutMs);

/// Sends a request to NATS server using the specified client and handles response via callbacks.
Future<void> sendRequestWithCallbacks(
        {required String clientId,
        required String subject,
        required String payload,
        required BigInt timeoutMs,
        required FutureOr<void> Function(String) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsSendRequestWithCallbacks(
        clientId: clientId,
        subject: subject,
        payload: payload,
        timeoutMs: timeoutMs,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Publishes a message to the specified subject using the specified client.
Future<void> publish(
        {required String clientId,
        required String subject,
        required String payload,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsPublish(
        clientId: clientId,
        subject: subject,
        payload: payload,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Sets up a responder to handle requests on a specified subject using the specified client.
Future<void> setupResponder(
        {required String clientId,
        required String subject,
        required String responderId,
        required FutureOr<String> Function(String) processRequest,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onError}) =>
    RustLib.instance.api.crateApiNatsSetupResponder(
        clientId: clientId,
        subject: subject,
        responderId: responderId,
        processRequest: processRequest,
        onSuccess: onSuccess,
        onError: onError);

/// Subscribes to a subject and receives messages via a callback using the specified client.
Future<void> subscribe(
        {required String clientId,
        required String subject,
        required String subscriptionId,
        required int maxMessages,
        required FutureOr<void> Function(String, String) onMessage,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onError,
        required FutureOr<void> Function() onDone}) =>
    RustLib.instance.api.crateApiNatsSubscribe(
        clientId: clientId,
        subject: subject,
        subscriptionId: subscriptionId,
        maxMessages: maxMessages,
        onMessage: onMessage,
        onSuccess: onSuccess,
        onError: onError,
        onDone: onDone);

/// Unsubscribes from a subject for the specified client.
Future<void> unsubscribe(
        {required String clientId,
        required String subscriptionId,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsUnsubscribe(
        clientId: clientId,
        subscriptionId: subscriptionId,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Returns a list of active subscription IDs for the specified client.
Future<List<String>> listSubscriptions({required String clientId}) =>
    RustLib.instance.api.crateApiNatsListSubscriptions(clientId: clientId);

/// Returns a list of connected client IDs.
Future<List<String>> listClients() =>
    RustLib.instance.api.crateApiNatsListClients();

/// Puts a value in the key-value store using JetStream for the specified client.
Future<void> kvPut(
        {required String clientId,
        required String bucketName,
        required String key,
        required String value,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsKvPut(
        clientId: clientId,
        bucketName: bucketName,
        key: key,
        value: value,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Gets a value from the key-value store using JetStream for the specified client.
Future<void> kvGet(
        {required String clientId,
        required String bucketName,
        required String key,
        required FutureOr<void> Function(String) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsKvGet(
        clientId: clientId,
        bucketName: bucketName,
        key: key,
        onSuccess: onSuccess,
        onFailure: onFailure);

/// Deletes a key from the key-value store using JetStream for the specified client.
Future<void> kvDelete(
        {required String clientId,
        required String bucketName,
        required String key,
        required FutureOr<void> Function(bool) onSuccess,
        required FutureOr<void> Function(String) onFailure}) =>
    RustLib.instance.api.crateApiNatsKvDelete(
        clientId: clientId,
        bucketName: bucketName,
        key: key,
        onSuccess: onSuccess,
        onFailure: onFailure);

class NatsConfig {
  final String host;
  final int port;
  final String? token;
  final String? nkey;
  final String? creds;
  final String? user;
  final String? pass;
  final ReconnectionConfig? reconnection;
  final BigInt? pingInterval;
  final int? maxPingFails;

  const NatsConfig({
    required this.host,
    required this.port,
    this.token,
    this.nkey,
    this.creds,
    this.user,
    this.pass,
    this.reconnection,
    this.pingInterval,
    this.maxPingFails,
  });

  @override
  int get hashCode =>
      host.hashCode ^
      port.hashCode ^
      token.hashCode ^
      nkey.hashCode ^
      creds.hashCode ^
      user.hashCode ^
      pass.hashCode ^
      reconnection.hashCode ^
      pingInterval.hashCode ^
      maxPingFails.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NatsConfig &&
          runtimeType == other.runtimeType &&
          host == other.host &&
          port == other.port &&
          token == other.token &&
          nkey == other.nkey &&
          creds == other.creds &&
          user == other.user &&
          pass == other.pass &&
          reconnection == other.reconnection &&
          pingInterval == other.pingInterval &&
          maxPingFails == other.maxPingFails;
}

class ReconnectionConfig {
  final int? maxAttempts;
  final BigInt? delay;

  const ReconnectionConfig({
    this.maxAttempts,
    this.delay,
  });

  @override
  int get hashCode => maxAttempts.hashCode ^ delay.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReconnectionConfig &&
          runtimeType == other.runtimeType &&
          maxAttempts == other.maxAttempts &&
          delay == other.delay;
}
