// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nats_playground_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NatsPlaygroundState {
  bool get isConnected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String get connectionStatus =>
      throw _privateConstructorUsedError; // Publish section
  String get publishStatus =>
      throw _privateConstructorUsedError; // Request section
  String get requestResponse => throw _privateConstructorUsedError;
  String get requestResponseTime =>
      throw _privateConstructorUsedError; // Responder section
  String get responderStatus => throw _privateConstructorUsedError;
  bool get isResponderActive => throw _privateConstructorUsedError;
  String get lastRequestReceived => throw _privateConstructorUsedError;
  String get lastRequestTime => throw _privateConstructorUsedError;
  String get responderID =>
      throw _privateConstructorUsedError; // Subscriber section
  String get subscriberStatus => throw _privateConstructorUsedError;
  bool get isSubscriberActive => throw _privateConstructorUsedError;
  String get lastPublishMsgReceived => throw _privateConstructorUsedError;
  String get lastPublishMsgTime => throw _privateConstructorUsedError;
  String get subscriberID =>
      throw _privateConstructorUsedError; // Key-Value section
  String get kvStatus => throw _privateConstructorUsedError;
  String get kvLastOperationTime => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)?
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)?
        initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of NatsPlaygroundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NatsPlaygroundStateCopyWith<NatsPlaygroundState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NatsPlaygroundStateCopyWith<$Res> {
  factory $NatsPlaygroundStateCopyWith(
          NatsPlaygroundState value, $Res Function(NatsPlaygroundState) then) =
      _$NatsPlaygroundStateCopyWithImpl<$Res, NatsPlaygroundState>;
  @useResult
  $Res call(
      {bool isConnected,
      bool isLoading,
      String connectionStatus,
      String publishStatus,
      String requestResponse,
      String requestResponseTime,
      String responderStatus,
      bool isResponderActive,
      String lastRequestReceived,
      String lastRequestTime,
      String responderID,
      String subscriberStatus,
      bool isSubscriberActive,
      String lastPublishMsgReceived,
      String lastPublishMsgTime,
      String subscriberID,
      String kvStatus,
      String kvLastOperationTime});
}

/// @nodoc
class _$NatsPlaygroundStateCopyWithImpl<$Res, $Val extends NatsPlaygroundState>
    implements $NatsPlaygroundStateCopyWith<$Res> {
  _$NatsPlaygroundStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NatsPlaygroundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isConnected = null,
    Object? isLoading = null,
    Object? connectionStatus = null,
    Object? publishStatus = null,
    Object? requestResponse = null,
    Object? requestResponseTime = null,
    Object? responderStatus = null,
    Object? isResponderActive = null,
    Object? lastRequestReceived = null,
    Object? lastRequestTime = null,
    Object? responderID = null,
    Object? subscriberStatus = null,
    Object? isSubscriberActive = null,
    Object? lastPublishMsgReceived = null,
    Object? lastPublishMsgTime = null,
    Object? subscriberID = null,
    Object? kvStatus = null,
    Object? kvLastOperationTime = null,
  }) {
    return _then(_value.copyWith(
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionStatus: null == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      publishStatus: null == publishStatus
          ? _value.publishStatus
          : publishStatus // ignore: cast_nullable_to_non_nullable
              as String,
      requestResponse: null == requestResponse
          ? _value.requestResponse
          : requestResponse // ignore: cast_nullable_to_non_nullable
              as String,
      requestResponseTime: null == requestResponseTime
          ? _value.requestResponseTime
          : requestResponseTime // ignore: cast_nullable_to_non_nullable
              as String,
      responderStatus: null == responderStatus
          ? _value.responderStatus
          : responderStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isResponderActive: null == isResponderActive
          ? _value.isResponderActive
          : isResponderActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastRequestReceived: null == lastRequestReceived
          ? _value.lastRequestReceived
          : lastRequestReceived // ignore: cast_nullable_to_non_nullable
              as String,
      lastRequestTime: null == lastRequestTime
          ? _value.lastRequestTime
          : lastRequestTime // ignore: cast_nullable_to_non_nullable
              as String,
      responderID: null == responderID
          ? _value.responderID
          : responderID // ignore: cast_nullable_to_non_nullable
              as String,
      subscriberStatus: null == subscriberStatus
          ? _value.subscriberStatus
          : subscriberStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isSubscriberActive: null == isSubscriberActive
          ? _value.isSubscriberActive
          : isSubscriberActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPublishMsgReceived: null == lastPublishMsgReceived
          ? _value.lastPublishMsgReceived
          : lastPublishMsgReceived // ignore: cast_nullable_to_non_nullable
              as String,
      lastPublishMsgTime: null == lastPublishMsgTime
          ? _value.lastPublishMsgTime
          : lastPublishMsgTime // ignore: cast_nullable_to_non_nullable
              as String,
      subscriberID: null == subscriberID
          ? _value.subscriberID
          : subscriberID // ignore: cast_nullable_to_non_nullable
              as String,
      kvStatus: null == kvStatus
          ? _value.kvStatus
          : kvStatus // ignore: cast_nullable_to_non_nullable
              as String,
      kvLastOperationTime: null == kvLastOperationTime
          ? _value.kvLastOperationTime
          : kvLastOperationTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res>
    implements $NatsPlaygroundStateCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isConnected,
      bool isLoading,
      String connectionStatus,
      String publishStatus,
      String requestResponse,
      String requestResponseTime,
      String responderStatus,
      bool isResponderActive,
      String lastRequestReceived,
      String lastRequestTime,
      String responderID,
      String subscriberStatus,
      bool isSubscriberActive,
      String lastPublishMsgReceived,
      String lastPublishMsgTime,
      String subscriberID,
      String kvStatus,
      String kvLastOperationTime});
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$NatsPlaygroundStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of NatsPlaygroundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isConnected = null,
    Object? isLoading = null,
    Object? connectionStatus = null,
    Object? publishStatus = null,
    Object? requestResponse = null,
    Object? requestResponseTime = null,
    Object? responderStatus = null,
    Object? isResponderActive = null,
    Object? lastRequestReceived = null,
    Object? lastRequestTime = null,
    Object? responderID = null,
    Object? subscriberStatus = null,
    Object? isSubscriberActive = null,
    Object? lastPublishMsgReceived = null,
    Object? lastPublishMsgTime = null,
    Object? subscriberID = null,
    Object? kvStatus = null,
    Object? kvLastOperationTime = null,
  }) {
    return _then(_$InitialImpl(
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionStatus: null == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      publishStatus: null == publishStatus
          ? _value.publishStatus
          : publishStatus // ignore: cast_nullable_to_non_nullable
              as String,
      requestResponse: null == requestResponse
          ? _value.requestResponse
          : requestResponse // ignore: cast_nullable_to_non_nullable
              as String,
      requestResponseTime: null == requestResponseTime
          ? _value.requestResponseTime
          : requestResponseTime // ignore: cast_nullable_to_non_nullable
              as String,
      responderStatus: null == responderStatus
          ? _value.responderStatus
          : responderStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isResponderActive: null == isResponderActive
          ? _value.isResponderActive
          : isResponderActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastRequestReceived: null == lastRequestReceived
          ? _value.lastRequestReceived
          : lastRequestReceived // ignore: cast_nullable_to_non_nullable
              as String,
      lastRequestTime: null == lastRequestTime
          ? _value.lastRequestTime
          : lastRequestTime // ignore: cast_nullable_to_non_nullable
              as String,
      responderID: null == responderID
          ? _value.responderID
          : responderID // ignore: cast_nullable_to_non_nullable
              as String,
      subscriberStatus: null == subscriberStatus
          ? _value.subscriberStatus
          : subscriberStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isSubscriberActive: null == isSubscriberActive
          ? _value.isSubscriberActive
          : isSubscriberActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPublishMsgReceived: null == lastPublishMsgReceived
          ? _value.lastPublishMsgReceived
          : lastPublishMsgReceived // ignore: cast_nullable_to_non_nullable
              as String,
      lastPublishMsgTime: null == lastPublishMsgTime
          ? _value.lastPublishMsgTime
          : lastPublishMsgTime // ignore: cast_nullable_to_non_nullable
              as String,
      subscriberID: null == subscriberID
          ? _value.subscriberID
          : subscriberID // ignore: cast_nullable_to_non_nullable
              as String,
      kvStatus: null == kvStatus
          ? _value.kvStatus
          : kvStatus // ignore: cast_nullable_to_non_nullable
              as String,
      kvLastOperationTime: null == kvLastOperationTime
          ? _value.kvLastOperationTime
          : kvLastOperationTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl(
      {this.isConnected = false,
      this.isLoading = false,
      this.connectionStatus = "Not connected",
      this.publishStatus = "No message published",
      this.requestResponse = "No request sent",
      this.requestResponseTime = "",
      this.responderStatus = "Responder not active",
      this.isResponderActive = false,
      this.lastRequestReceived = "No requests yet",
      this.lastRequestTime = "",
      this.responderID = "responder-123",
      this.subscriberStatus = "Subscriber not active",
      this.isSubscriberActive = false,
      this.lastPublishMsgReceived = "No messages yet",
      this.lastPublishMsgTime = "",
      this.subscriberID = "subscriber-123",
      this.kvStatus = "No KV operations performed",
      this.kvLastOperationTime = ""});

  @override
  @JsonKey()
  final bool isConnected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String connectionStatus;
// Publish section
  @override
  @JsonKey()
  final String publishStatus;
// Request section
  @override
  @JsonKey()
  final String requestResponse;
  @override
  @JsonKey()
  final String requestResponseTime;
// Responder section
  @override
  @JsonKey()
  final String responderStatus;
  @override
  @JsonKey()
  final bool isResponderActive;
  @override
  @JsonKey()
  final String lastRequestReceived;
  @override
  @JsonKey()
  final String lastRequestTime;
  @override
  @JsonKey()
  final String responderID;
// Subscriber section
  @override
  @JsonKey()
  final String subscriberStatus;
  @override
  @JsonKey()
  final bool isSubscriberActive;
  @override
  @JsonKey()
  final String lastPublishMsgReceived;
  @override
  @JsonKey()
  final String lastPublishMsgTime;
  @override
  @JsonKey()
  final String subscriberID;
// Key-Value section
  @override
  @JsonKey()
  final String kvStatus;
  @override
  @JsonKey()
  final String kvLastOperationTime;

  @override
  String toString() {
    return 'NatsPlaygroundState.initial(isConnected: $isConnected, isLoading: $isLoading, connectionStatus: $connectionStatus, publishStatus: $publishStatus, requestResponse: $requestResponse, requestResponseTime: $requestResponseTime, responderStatus: $responderStatus, isResponderActive: $isResponderActive, lastRequestReceived: $lastRequestReceived, lastRequestTime: $lastRequestTime, responderID: $responderID, subscriberStatus: $subscriberStatus, isSubscriberActive: $isSubscriberActive, lastPublishMsgReceived: $lastPublishMsgReceived, lastPublishMsgTime: $lastPublishMsgTime, subscriberID: $subscriberID, kvStatus: $kvStatus, kvLastOperationTime: $kvLastOperationTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitialImpl &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.connectionStatus, connectionStatus) ||
                other.connectionStatus == connectionStatus) &&
            (identical(other.publishStatus, publishStatus) ||
                other.publishStatus == publishStatus) &&
            (identical(other.requestResponse, requestResponse) ||
                other.requestResponse == requestResponse) &&
            (identical(other.requestResponseTime, requestResponseTime) ||
                other.requestResponseTime == requestResponseTime) &&
            (identical(other.responderStatus, responderStatus) ||
                other.responderStatus == responderStatus) &&
            (identical(other.isResponderActive, isResponderActive) ||
                other.isResponderActive == isResponderActive) &&
            (identical(other.lastRequestReceived, lastRequestReceived) ||
                other.lastRequestReceived == lastRequestReceived) &&
            (identical(other.lastRequestTime, lastRequestTime) ||
                other.lastRequestTime == lastRequestTime) &&
            (identical(other.responderID, responderID) ||
                other.responderID == responderID) &&
            (identical(other.subscriberStatus, subscriberStatus) ||
                other.subscriberStatus == subscriberStatus) &&
            (identical(other.isSubscriberActive, isSubscriberActive) ||
                other.isSubscriberActive == isSubscriberActive) &&
            (identical(other.lastPublishMsgReceived, lastPublishMsgReceived) ||
                other.lastPublishMsgReceived == lastPublishMsgReceived) &&
            (identical(other.lastPublishMsgTime, lastPublishMsgTime) ||
                other.lastPublishMsgTime == lastPublishMsgTime) &&
            (identical(other.subscriberID, subscriberID) ||
                other.subscriberID == subscriberID) &&
            (identical(other.kvStatus, kvStatus) ||
                other.kvStatus == kvStatus) &&
            (identical(other.kvLastOperationTime, kvLastOperationTime) ||
                other.kvLastOperationTime == kvLastOperationTime));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isConnected,
      isLoading,
      connectionStatus,
      publishStatus,
      requestResponse,
      requestResponseTime,
      responderStatus,
      isResponderActive,
      lastRequestReceived,
      lastRequestTime,
      responderID,
      subscriberStatus,
      isSubscriberActive,
      lastPublishMsgReceived,
      lastPublishMsgTime,
      subscriberID,
      kvStatus,
      kvLastOperationTime);

  /// Create a copy of NatsPlaygroundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      __$$InitialImplCopyWithImpl<_$InitialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)
        initial,
  }) {
    return initial(
        isConnected,
        isLoading,
        connectionStatus,
        publishStatus,
        requestResponse,
        requestResponseTime,
        responderStatus,
        isResponderActive,
        lastRequestReceived,
        lastRequestTime,
        responderID,
        subscriberStatus,
        isSubscriberActive,
        lastPublishMsgReceived,
        lastPublishMsgTime,
        subscriberID,
        kvStatus,
        kvLastOperationTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)?
        initial,
  }) {
    return initial?.call(
        isConnected,
        isLoading,
        connectionStatus,
        publishStatus,
        requestResponse,
        requestResponseTime,
        responderStatus,
        isResponderActive,
        lastRequestReceived,
        lastRequestTime,
        responderID,
        subscriberStatus,
        isSubscriberActive,
        lastPublishMsgReceived,
        lastPublishMsgTime,
        subscriberID,
        kvStatus,
        kvLastOperationTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            bool isConnected,
            bool isLoading,
            String connectionStatus,
            String publishStatus,
            String requestResponse,
            String requestResponseTime,
            String responderStatus,
            bool isResponderActive,
            String lastRequestReceived,
            String lastRequestTime,
            String responderID,
            String subscriberStatus,
            bool isSubscriberActive,
            String lastPublishMsgReceived,
            String lastPublishMsgTime,
            String subscriberID,
            String kvStatus,
            String kvLastOperationTime)?
        initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(
          isConnected,
          isLoading,
          connectionStatus,
          publishStatus,
          requestResponse,
          requestResponseTime,
          responderStatus,
          isResponderActive,
          lastRequestReceived,
          lastRequestTime,
          responderID,
          subscriberStatus,
          isSubscriberActive,
          lastPublishMsgReceived,
          lastPublishMsgTime,
          subscriberID,
          kvStatus,
          kvLastOperationTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements NatsPlaygroundState {
  const factory _Initial(
      {final bool isConnected,
      final bool isLoading,
      final String connectionStatus,
      final String publishStatus,
      final String requestResponse,
      final String requestResponseTime,
      final String responderStatus,
      final bool isResponderActive,
      final String lastRequestReceived,
      final String lastRequestTime,
      final String responderID,
      final String subscriberStatus,
      final bool isSubscriberActive,
      final String lastPublishMsgReceived,
      final String lastPublishMsgTime,
      final String subscriberID,
      final String kvStatus,
      final String kvLastOperationTime}) = _$InitialImpl;

  @override
  bool get isConnected;
  @override
  bool get isLoading;
  @override
  String get connectionStatus; // Publish section
  @override
  String get publishStatus; // Request section
  @override
  String get requestResponse;
  @override
  String get requestResponseTime; // Responder section
  @override
  String get responderStatus;
  @override
  bool get isResponderActive;
  @override
  String get lastRequestReceived;
  @override
  String get lastRequestTime;
  @override
  String get responderID; // Subscriber section
  @override
  String get subscriberStatus;
  @override
  bool get isSubscriberActive;
  @override
  String get lastPublishMsgReceived;
  @override
  String get lastPublishMsgTime;
  @override
  String get subscriberID; // Key-Value section
  @override
  String get kvStatus;
  @override
  String get kvLastOperationTime;

  /// Create a copy of NatsPlaygroundState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InitialImplCopyWith<_$InitialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
