import 'package:example/common/di/injection.dart';
import 'package:example/presentation/view/nats_playground/cubit/nats_playground_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nats/flutter_nats.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NatsPlaygroundPage extends StatefulWidget {
  const NatsPlaygroundPage({super.key});

  @override
  NatsPlaygroundPageState createState() => NatsPlaygroundPageState();
}

class NatsPlaygroundPageState extends State<NatsPlaygroundPage> {
  final cubit = getIt<NatsPlaygroundCubit>();

  String _connectionStatus = "Not connected";

  String _publishStatus = "No message published";

  String _requestResponse = "No request sent";
  String _requestResponseTime = "";

  String _responderStatus = "Responder not active";
  bool _isResponderActive = false;
  String _lastRequestReceived = "No requests yet";
  String _lastRequestTime = "";
  final String _responderID = "responder-123";

  String _subscriberStatus = "Subscriber not active";
  bool _isSubscriberActive = false;
  String _lastPublishMsgReceived = "No messages yet";
  String _lastPublishMsgTime = "";
  final String _subscriberID = "subscriber-123";


  String _kvStatus = "No KV operations performed";
  String _kvLastOperationTime = "";

  @override
  void initState() {
    super.initState();
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final host = cubit.controllers.hostController.text;
        final port = int.tryParse(cubit.controllers.portController.text) ?? 4222;
        // Create a new NatsConfig
        final config = NatsConfig(
          host: host,
          port: port,
        );
        cubit.initNatsController(config: config);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "NATS Playground",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF2C3E50),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionSection(),
                  _buildRequestSection(),
                  _buildResponderSection(),
                  _buildPublishSection(),
                  _buildSubscribeSection(),
                  _buildKeyValueSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
              buildWhen: (prev, curr) {
                return prev.isLoading != curr.isLoading;
              },
              builder: (context, state) {
                return Visibility(
                  visible: state.isLoading,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // UI SECTIONS

  Widget _buildConnectionSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.network_wifi, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Connection",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                // Replace single endpoint text field with separate host and port fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: cubit.controllers.hostController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: "Host",
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: "127.0.0.1",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: cubit.controllers.portController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: "Port",
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: "4222",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !state.isConnected ? _connect : null,
                        child: const Text("Connect", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isConnected ? _disconnect : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Disconnect", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: state.isConnected ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isConnected ? Colors.green.shade300 : Colors.red.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.isConnected ? Icons.check_circle : Icons.error,
                        color: state.isConnected ? Colors.green.shade700 : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Status: $_connectionStatus",
                          style: TextStyle(
                            color: state.isConnected ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.send, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Request",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                TextField(
                  controller: cubit.controllers.requestSubjectController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.controllers.requestMessageController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Message",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isConnected ? _sendRequest : null,
                    child: const Text("Send Request", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Response:",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _requestResponse,
                        style: const TextStyle(fontSize: 15),
                      ),
                      if (_requestResponseTime.isNotEmpty) const Divider(height: 24),
                      if (_requestResponseTime.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              _requestResponseTime,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponderSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.reply_all, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Responder",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                TextField(
                  controller: cubit.controllers.responderSubjectController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.controllers.responderReplyController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Reply Message",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isConnected && !_isResponderActive ? _startResponder : null,
                          child: const Text("Start", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isResponderActive ? _stopResponder : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Stop", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isResponderActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isResponderActive ? Colors.green.shade300 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isResponderActive ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _isResponderActive ? Colors.green.shade700 : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Status: $_responderStatus",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isResponderActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_lastRequestReceived != "No requests yet") const Divider(height: 24),
                      if (_lastRequestReceived != "No requests yet")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Last request:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lastRequestReceived,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  _lastRequestTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublishSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.publish, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Publish",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                TextField(
                  controller: cubit.controllers.publishSubjectController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.controllers.publishMessageController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Message",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isConnected ? _publish : null,
                    child: const Text("Publish", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  ),
                  child: Text(
                    "Status: $_publishStatus",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscribeSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Subscribe",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                TextField(
                  controller: cubit.controllers.subscribeSubjectController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isConnected && !_isSubscriberActive ? _startSubscriber : null,
                          child: const Text("Start", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubscriberActive ? _stopSubscriber : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Stop", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSubscriberActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSubscriberActive ? Colors.green.shade300 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSubscriberActive ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _isSubscriberActive ? Colors.green.shade700 : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Status: $_subscriberStatus",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isSubscriberActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_lastPublishMsgReceived != "No messages yet" && _lastPublishMsgReceived != "No requests yet")
                        const Divider(height: 24),
                      if (_lastPublishMsgReceived != "No messages yet" && _lastPublishMsgReceived != "No requests yet")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Last message:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lastPublishMsgReceived,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  _lastPublishMsgTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyValueSection() {
    return BlocBuilder<NatsPlaygroundCubit, NatsPlaygroundState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage, size: 24, color: Color(0xFF2C3E50)),
                    const SizedBox(width: 12),
                    Text(
                      "Key-Value Store",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2C3E50),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                TextField(
                  controller: cubit.controllers.kvBucketController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Bucket",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.controllers.kvKeyController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: "Key",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.controllers.kvValueController,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Value",
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isConnected ? _putValue : null,
                          child: const Text("Put", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isConnected ? _getValue : null,
                          child: const Text("Get", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isConnected ? _deleteValue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Delete", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: $_kvStatus",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (_kvLastOperationTime.isNotEmpty) const Divider(height: 24),
                      if (_kvLastOperationTime.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              _kvLastOperationTime,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // CONNECTION FUNCTIONS
  void _connect() {
    cubit.updateLoadingStatus(true);

    final host = cubit.controllers.hostController.text;
    final port = int.tryParse(cubit.controllers.portController.text) ?? 4222;

    // Create a new NatsConfig
    final config = NatsConfig(
      host: host,
      port: port,
    );

    // Update the controller if config changed
    if (cubit.natsController.config.host != config.host || cubit.natsController.config.port != config.port) {
      cubit.initNatsController(config: config);
    }

    cubit.natsController.connect(
      onSuccess: (isConnected) {
        setState(() {
          _connectionStatus = "Connected";
          cubit.updateConnectionStatus(true);
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorString) {
        setState(() {
          _connectionStatus = "Not Connected - $errorString";
          cubit.updateConnectionStatus(false);
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  void _disconnect() {
    cubit.updateLoadingStatus(true);
    cubit.natsController.disconnect(
      onSuccess: (isSuccess) {
        setState(() {
          _connectionStatus = "Disconnected";
          cubit.updateConnectionStatus(false);
          _isResponderActive = false;
          _isSubscriberActive = false;
          _responderStatus = "Responder not active";
          _subscriberStatus = "Subscriber not active";
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _connectionStatus = "Disconnect error: $errorMessage";
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  // PUBLISH FUNCTIONS
  void _publish() {
    cubit.natsController.publish(
      subject: cubit.controllers.publishSubjectController.text,
      payload: cubit.controllers.publishMessageController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _publishStatus = "Message published successfully at ${_formatTimestamp()}";
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _publishStatus = "Publish error: $errorMessage";
        });
      },
    );
  }

  // REQUEST FUNCTIONS
  void _sendRequest() {
    cubit.updateLoadingStatus(true);
    cubit.natsController.sendRequestWithCallbacks(
      subject: cubit.controllers.requestSubjectController.text,
      payload: cubit.controllers.requestMessageController.text,
      timeoutMs: 5000,
      onSuccess: (successMessage) {
        setState(() {
          _requestResponse = successMessage;
          _requestResponseTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _requestResponse = "Request error: $errorMessage";
          _requestResponseTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  // RESPONDER FUNCTIONS
  void _startResponder() {
    cubit.natsController.setupResponder(
      subject: cubit.controllers.responderSubjectController.text,
      responderId: _responderID,
      processRequest: (requestMessage) async {
        setState(() {
          _lastRequestReceived = requestMessage;
          _lastRequestTime = _formatTimestamp();
        });
        return cubit.controllers.responderReplyController.text;
      },
      onSuccess: (isSuccess) {
        setState(() {
          _responderStatus = "Responder active";
          _isResponderActive = true;
        });
      },
      onError: (errorMessage) {
        setState(() {
          _responderStatus = "Responder error: $errorMessage";
        });
      },
    );
  }

  void _stopResponder() {
    cubit.natsController.unsubscribe(
      subscriptionId: _responderID,
      onSuccess: (isSuccess) {
        setState(() {
          _responderStatus = "Responder not active";
          _isResponderActive = false;
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _responderStatus = "Stop responder error: $errorMessage";
        });
      },
    );
  }

  // SUBSCRIBER FUNCTIONS
  void _startSubscriber() {
    cubit.natsController.subscribe(
      subject: cubit.controllers.subscribeSubjectController.text,
      subscriptionId: _subscriberID,
      maxMessages: 1000,
      onMessage: (topic, message) {
        setState(() {
          _lastPublishMsgReceived = message;
          _lastPublishMsgTime = _formatTimestamp();
        });
      },
      onSuccess: (isSuccess) {
        setState(() {
          _subscriberStatus = "Subscriber active";
          _isSubscriberActive = true;
        });
      },
      onError: (errorMessage) {
        setState(() {
          _subscriberStatus = "Subscriber error: $errorMessage";
          _isSubscriberActive = false;
        });
      },
      onDone: () {
        setState(() {
          _subscriberStatus = "Subscription completed";
          _isSubscriberActive = false;
        });
      },
    );
  }

  void _stopSubscriber() {
    cubit.natsController.unsubscribe(
      subscriptionId: _subscriberID,
      onSuccess: (isSuccess) {
        setState(() {
          _subscriberStatus = "Subscriber not active";
          _isSubscriberActive = false;
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _subscriberStatus = "Stop subscriber error: $errorMessage";
        });
      },
    );
  }

  // KEY-VALUE FUNCTIONS
  void _putValue() {
    cubit.updateLoadingStatus(true);
    cubit.natsController.kvPut(
      bucketName: cubit.controllers.kvBucketController.text,
      key: cubit.controllers.kvKeyController.text,
      value: cubit.controllers.kvValueController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _kvStatus = "Value stored successfully";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Put error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  void _getValue() {
    cubit.updateLoadingStatus(true);
    cubit.natsController.kvGet(
      bucketName: cubit.controllers.kvBucketController.text,
      key: cubit.controllers.kvKeyController.text,
      onSuccess: (value) {
        setState(() {
          cubit.controllers.kvValueController.text = value;
          _kvStatus = "Value retrieved successfully";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Get error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  void _deleteValue() {
    cubit.updateLoadingStatus(true);
    cubit.natsController.kvDelete(
      bucketName: cubit.controllers.kvBucketController.text,
      key: cubit.controllers.kvKeyController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _kvStatus = "Key deleted successfully";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Delete error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  @override
  void dispose() {
    cubit.controllers.hostController.dispose();
    cubit.controllers.portController.dispose();
    cubit.controllers.requestSubjectController.dispose();
    cubit.controllers.requestMessageController.dispose();
    cubit.controllers.publishSubjectController.dispose();
    cubit.controllers.publishMessageController.dispose();
    cubit.controllers.responderSubjectController.dispose();
    cubit.controllers.responderReplyController.dispose();
    cubit.controllers.subscribeSubjectController.dispose();
    cubit.controllers.kvBucketController.dispose();
    cubit.controllers.kvKeyController.dispose();
    cubit.controllers.kvValueController.dispose();
    super.dispose();
  }
}
