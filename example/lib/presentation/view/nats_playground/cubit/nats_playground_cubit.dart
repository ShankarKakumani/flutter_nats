import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nats/flutter_nats.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'nats_playground_state.dart';
part 'nats_playground_cubit.freezed.dart';

@injectable
class NatsPlaygroundCubit extends Cubit<NatsPlaygroundState> {
  NatsPlaygroundCubit(
    this.controllers,
  ) : super(const NatsPlaygroundState.initial());

  final NatsPlayGroundControllers controllers;
  late NatsController _natsController;

  NatsController get natsController => _natsController;

  void initNatsController({required NatsConfig config}) {
    _natsController = NatsController(
      config: config,
    );
  }

  // Connection section
  void updateLoadingStatus(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  void updateConnectionStatus(bool value) {
    emit(state.copyWith(isConnected: value));
  }
  
  void updateConnectionStatusText(String value) {
    emit(state.copyWith(connectionStatus: value));
  }
  
  // Publish section
  void updatePublishStatus(String value) {
    emit(state.copyWith(publishStatus: value));
  }
  
  // Request section
  void updateRequestResponse(String value) {
    emit(state.copyWith(requestResponse: value));
  }
  
  void updateRequestResponseTime(String value) {
    emit(state.copyWith(requestResponseTime: value));
  }
  
  // Responder section
  void updateResponderStatus(String value) {
    emit(state.copyWith(responderStatus: value));
  }
  
  void updateResponderActive(bool value) {
    emit(state.copyWith(isResponderActive: value));
  }
  
  void updateLastRequestReceived(String value) {
    emit(state.copyWith(lastRequestReceived: value));
  }
  
  void updateLastRequestTime(String value) {
    emit(state.copyWith(lastRequestTime: value));
  }
  
  // Subscriber section
  void updateSubscriberStatus(String value) {
    emit(state.copyWith(subscriberStatus: value));
  }
  
  void updateSubscriberActive(bool value) {
    emit(state.copyWith(isSubscriberActive: value));
  }
  
  void updateLastPublishMsgReceived(String value) {
    emit(state.copyWith(lastPublishMsgReceived: value));
  }
  
  void updateLastPublishMsgTime(String value) {
    emit(state.copyWith(lastPublishMsgTime: value));
  }
  
  // Key-Value section
  void updateKvStatus(String value) {
    emit(state.copyWith(kvStatus: value));
  }
  
  void updateKvLastOperationTime(String value) {
    emit(state.copyWith(kvLastOperationTime: value));
  }
}

@injectable
class NatsPlayGroundControllers {
  // Connection Section
  final TextEditingController hostController = TextEditingController(text: "127.0.0.1");
  final TextEditingController portController = TextEditingController(text: "4222");

  // Publish Section
  final TextEditingController publishSubjectController = TextEditingController(text: "topic_publish");
  final TextEditingController publishMessageController = TextEditingController(text: "Hello from Publisher!");

  // Request Section
  final TextEditingController requestSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController requestMessageController = TextEditingController(text: "Hello, NATS!");

  // Responder Section
  final TextEditingController responderSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController responderReplyController = TextEditingController(text: "Hello from Flutter!");

  // Subscriber Section
  final TextEditingController subscribeSubjectController = TextEditingController(text: "topic_publish");

  // Key-Value Section
  final TextEditingController kvBucketController = TextEditingController(text: "my-bucket");
  final TextEditingController kvKeyController = TextEditingController(text: "my-key");
  final TextEditingController kvValueController = TextEditingController(text: "Hello KV Store!");
}
