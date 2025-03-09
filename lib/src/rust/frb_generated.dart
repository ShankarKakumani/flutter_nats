// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.8.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/rust.dart';
import 'api/rust_manager.dart';
import 'api/simple.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'frb_generated.io.dart'
    if (dart.library.js_interop) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Initialize flutter_rust_bridge in mock mode.
  /// No libraries for FFI are loaded.
  static void initMock({
    required RustLibApi api,
  }) {
    instance.initMockImpl(
      api: api,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiRustInitApp();
    await api.crateApiRustManagerInitApp();
    await api.crateApiSimpleInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.8.0';

  @override
  int get rustContentHash => 317694745;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'rust_lib_flutter_nats',
    ioDirectory: 'rust/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  String crateApiRustConnectSync({required String natsUrl});

  Future<void> crateApiRustManagerConnectToNats(
      {required String endPoint,
      required FutureOr<void> Function(bool) onSuccess,
      required FutureOr<void> Function(String) onFailure});

  String crateApiRustDisconnectSync();

  Future<void> crateApiRustManagerFunWithOnlyCallback(
      {required FutureOr<bool> Function(String) dartCallback});

  Future<void> crateApiRustManagerFunWithReturnCallback(
      {required FutureOr<String> Function(String) dartCallback});

  String crateApiSimpleGreet({required String name});

  Future<void> crateApiRustInitApp();

  Future<void> crateApiRustManagerInitApp();

  Future<void> crateApiSimpleInitApp();

  Future<void> crateApiSimpleRustFunction(
      {required FutureOr<String> Function(String) dartCallback});

  String crateApiRustSendRequestSync(
      {required String natsUrl,
      required String subject,
      required String message});

  String crateApiRustStartResponderSync(
      {required String natsUrl,
      required String subject,
      required String replyMessage});

  String crateApiRustStopResponderSync();
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  String crateApiRustConnectSync({required String natsUrl}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(natsUrl, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 4)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiRustConnectSyncConstMeta,
      argValues: [natsUrl],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustConnectSyncConstMeta => const TaskConstMeta(
        debugName: "connect_sync",
        argNames: ["natsUrl"],
      );

  @override
  Future<void> crateApiRustManagerConnectToNats(
      {required String endPoint,
      required FutureOr<void> Function(bool) onSuccess,
      required FutureOr<void> Function(String) onFailure}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(endPoint, serializer);
        sse_encode_DartFn_Inputs_bool_Output_unit_AnyhowException(
            onSuccess, serializer);
        sse_encode_DartFn_Inputs_String_Output_unit_AnyhowException(
            onFailure, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 5, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRustManagerConnectToNatsConstMeta,
      argValues: [endPoint, onSuccess, onFailure],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustManagerConnectToNatsConstMeta =>
      const TaskConstMeta(
        debugName: "connect_to_nats",
        argNames: ["endPoint", "onSuccess", "onFailure"],
      );

  @override
  String crateApiRustDisconnectSync() {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 6)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiRustDisconnectSyncConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustDisconnectSyncConstMeta => const TaskConstMeta(
        debugName: "disconnect_sync",
        argNames: [],
      );

  @override
  Future<void> crateApiRustManagerFunWithOnlyCallback(
      {required FutureOr<bool> Function(String) dartCallback}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_DartFn_Inputs_String_Output_bool_AnyhowException(
            dartCallback, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 7, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRustManagerFunWithOnlyCallbackConstMeta,
      argValues: [dartCallback],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustManagerFunWithOnlyCallbackConstMeta =>
      const TaskConstMeta(
        debugName: "fun_with_only_callback",
        argNames: ["dartCallback"],
      );

  @override
  Future<void> crateApiRustManagerFunWithReturnCallback(
      {required FutureOr<String> Function(String) dartCallback}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_DartFn_Inputs_String_Output_String_AnyhowException(
            dartCallback, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 8, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRustManagerFunWithReturnCallbackConstMeta,
      argValues: [dartCallback],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustManagerFunWithReturnCallbackConstMeta =>
      const TaskConstMeta(
        debugName: "fun_with_return_callback",
        argNames: ["dartCallback"],
      );

  @override
  String crateApiSimpleGreet({required String name}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(name, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 9)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiSimpleGreetConstMeta,
      argValues: [name],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiSimpleGreetConstMeta => const TaskConstMeta(
        debugName: "greet",
        argNames: ["name"],
      );

  @override
  Future<void> crateApiRustInitApp() {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 10, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRustInitAppConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @override
  Future<void> crateApiRustManagerInitApp() {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 11, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiRustManagerInitAppConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustManagerInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @override
  Future<void> crateApiSimpleInitApp() {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 12, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiSimpleInitAppConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiSimpleInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @override
  Future<void> crateApiSimpleRustFunction(
      {required FutureOr<String> Function(String) dartCallback}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_DartFn_Inputs_String_Output_String_AnyhowException(
            dartCallback, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 13, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiSimpleRustFunctionConstMeta,
      argValues: [dartCallback],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiSimpleRustFunctionConstMeta => const TaskConstMeta(
        debugName: "rust_function",
        argNames: ["dartCallback"],
      );

  @override
  String crateApiRustSendRequestSync(
      {required String natsUrl,
      required String subject,
      required String message}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(natsUrl, serializer);
        sse_encode_String(subject, serializer);
        sse_encode_String(message, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 14)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiRustSendRequestSyncConstMeta,
      argValues: [natsUrl, subject, message],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustSendRequestSyncConstMeta =>
      const TaskConstMeta(
        debugName: "send_request_sync",
        argNames: ["natsUrl", "subject", "message"],
      );

  @override
  String crateApiRustStartResponderSync(
      {required String natsUrl,
      required String subject,
      required String replyMessage}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_String(natsUrl, serializer);
        sse_encode_String(subject, serializer);
        sse_encode_String(replyMessage, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 15)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiRustStartResponderSyncConstMeta,
      argValues: [natsUrl, subject, replyMessage],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustStartResponderSyncConstMeta =>
      const TaskConstMeta(
        debugName: "start_responder_sync",
        argNames: ["natsUrl", "subject", "replyMessage"],
      );

  @override
  String crateApiRustStopResponderSync() {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 16)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: sse_decode_String,
      ),
      constMeta: kCrateApiRustStopResponderSyncConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiRustStopResponderSyncConstMeta =>
      const TaskConstMeta(
        debugName: "stop_responder_sync",
        argNames: [],
      );

  Future<void> Function(int, dynamic)
      encode_DartFn_Inputs_String_Output_String_AnyhowException(
          FutureOr<String> Function(String) raw) {
    return (callId, rawArg0) async {
      final arg0 = dco_decode_String(rawArg0);

      Box<String>? rawOutput;
      Box<AnyhowException>? rawError;
      try {
        rawOutput = Box(await raw(arg0));
      } catch (e, s) {
        rawError = Box(AnyhowException("$e\n\n$s"));
      }

      final serializer = SseSerializer(generalizedFrbRustBinding);
      assert((rawOutput != null) ^ (rawError != null));
      if (rawOutput != null) {
        serializer.buffer.putUint8(0);
        sse_encode_String(rawOutput.value, serializer);
      } else {
        serializer.buffer.putUint8(1);
        sse_encode_AnyhowException(rawError!.value, serializer);
      }
      final output = serializer.intoRaw();

      generalizedFrbRustBinding.dartFnDeliverOutput(
          callId: callId,
          ptr: output.ptr,
          rustVecLen: output.rustVecLen,
          dataLen: output.dataLen);
    };
  }

  Future<void> Function(int, dynamic)
      encode_DartFn_Inputs_String_Output_bool_AnyhowException(
          FutureOr<bool> Function(String) raw) {
    return (callId, rawArg0) async {
      final arg0 = dco_decode_String(rawArg0);

      Box<bool>? rawOutput;
      Box<AnyhowException>? rawError;
      try {
        rawOutput = Box(await raw(arg0));
      } catch (e, s) {
        rawError = Box(AnyhowException("$e\n\n$s"));
      }

      final serializer = SseSerializer(generalizedFrbRustBinding);
      assert((rawOutput != null) ^ (rawError != null));
      if (rawOutput != null) {
        serializer.buffer.putUint8(0);
        sse_encode_bool(rawOutput.value, serializer);
      } else {
        serializer.buffer.putUint8(1);
        sse_encode_AnyhowException(rawError!.value, serializer);
      }
      final output = serializer.intoRaw();

      generalizedFrbRustBinding.dartFnDeliverOutput(
          callId: callId,
          ptr: output.ptr,
          rustVecLen: output.rustVecLen,
          dataLen: output.dataLen);
    };
  }

  Future<void> Function(int, dynamic)
      encode_DartFn_Inputs_String_Output_unit_AnyhowException(
          FutureOr<void> Function(String) raw) {
    return (callId, rawArg0) async {
      final arg0 = dco_decode_String(rawArg0);

      Box<void>? rawOutput;
      Box<AnyhowException>? rawError;
      try {
        rawOutput = Box(await raw(arg0));
      } catch (e, s) {
        rawError = Box(AnyhowException("$e\n\n$s"));
      }

      final serializer = SseSerializer(generalizedFrbRustBinding);
      assert((rawOutput != null) ^ (rawError != null));
      if (rawOutput != null) {
        serializer.buffer.putUint8(0);
        sse_encode_unit(rawOutput.value, serializer);
      } else {
        serializer.buffer.putUint8(1);
        sse_encode_AnyhowException(rawError!.value, serializer);
      }
      final output = serializer.intoRaw();

      generalizedFrbRustBinding.dartFnDeliverOutput(
          callId: callId,
          ptr: output.ptr,
          rustVecLen: output.rustVecLen,
          dataLen: output.dataLen);
    };
  }

  Future<void> Function(int, dynamic)
      encode_DartFn_Inputs_bool_Output_unit_AnyhowException(
          FutureOr<void> Function(bool) raw) {
    return (callId, rawArg0) async {
      final arg0 = dco_decode_bool(rawArg0);

      Box<void>? rawOutput;
      Box<AnyhowException>? rawError;
      try {
        rawOutput = Box(await raw(arg0));
      } catch (e, s) {
        rawError = Box(AnyhowException("$e\n\n$s"));
      }

      final serializer = SseSerializer(generalizedFrbRustBinding);
      assert((rawOutput != null) ^ (rawError != null));
      if (rawOutput != null) {
        serializer.buffer.putUint8(0);
        sse_encode_unit(rawOutput.value, serializer);
      } else {
        serializer.buffer.putUint8(1);
        sse_encode_AnyhowException(rawError!.value, serializer);
      }
      final output = serializer.intoRaw();

      generalizedFrbRustBinding.dartFnDeliverOutput(
          callId: callId,
          ptr: output.ptr,
          rustVecLen: output.rustVecLen,
          dataLen: output.dataLen);
    };
  }

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return AnyhowException(raw as String);
  }

  @protected
  FutureOr<String> Function(String)
      dco_decode_DartFn_Inputs_String_Output_String_AnyhowException(
          dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError('');
  }

  @protected
  FutureOr<bool> Function(String)
      dco_decode_DartFn_Inputs_String_Output_bool_AnyhowException(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError('');
  }

  @protected
  FutureOr<void> Function(String)
      dco_decode_DartFn_Inputs_String_Output_unit_AnyhowException(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError('');
  }

  @protected
  FutureOr<void> Function(bool)
      dco_decode_DartFn_Inputs_bool_Output_unit_AnyhowException(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError('');
  }

  @protected
  Object dco_decode_DartOpaque(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return decodeDartOpaque(raw, generalizedFrbRustBinding);
  }

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  ConnectionCallback dco_decode_TraitDef_ConnectionCallback(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError();
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as bool;
  }

  @protected
  int dco_decode_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  PlatformInt64 dco_decode_isize(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeI64(raw);
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  BigInt dco_decode_usize(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeU64(raw);
  }

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_String(deserializer);
    return AnyhowException(inner);
  }

  @protected
  Object sse_decode_DartOpaque(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_isize(deserializer);
    return decodeDartOpaque(inner, generalizedFrbRustBinding);
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  PlatformInt64 sse_decode_isize(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getPlatformInt64();
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getBigUint64();
  }

  @protected
  void sse_encode_AnyhowException(
      AnyhowException self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.message, serializer);
  }

  @protected
  void sse_encode_DartFn_Inputs_String_Output_String_AnyhowException(
      FutureOr<String> Function(String) self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_DartOpaque(
        encode_DartFn_Inputs_String_Output_String_AnyhowException(self),
        serializer);
  }

  @protected
  void sse_encode_DartFn_Inputs_String_Output_bool_AnyhowException(
      FutureOr<bool> Function(String) self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_DartOpaque(
        encode_DartFn_Inputs_String_Output_bool_AnyhowException(self),
        serializer);
  }

  @protected
  void sse_encode_DartFn_Inputs_String_Output_unit_AnyhowException(
      FutureOr<void> Function(String) self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_DartOpaque(
        encode_DartFn_Inputs_String_Output_unit_AnyhowException(self),
        serializer);
  }

  @protected
  void sse_encode_DartFn_Inputs_bool_Output_unit_AnyhowException(
      FutureOr<void> Function(bool) self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_DartOpaque(
        encode_DartFn_Inputs_bool_Output_unit_AnyhowException(self),
        serializer);
  }

  @protected
  void sse_encode_DartOpaque(Object self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_isize(
        PlatformPointerUtil.ptrToPlatformInt64(encodeDartOpaque(
            self, portManager.dartHandlerPort, generalizedFrbRustBinding)),
        serializer);
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_isize(PlatformInt64 self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putPlatformInt64(self);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putBigUint64(self);
  }
}
