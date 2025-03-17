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
                    color: Colors.black.withValues(alpha: 0.3),
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.connectionStatus != curr.connectionStatus;
        var c3 = prev.isLoading != curr.isLoading;
        return c1 || c2 || c3;
      },
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
                          "Status: ${state.connectionStatus}",
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.requestResponse != curr.requestResponse;
        var c3 = prev.requestResponseTime != curr.requestResponseTime;
        return c1 || c2 || c3;
      },
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
                        state.requestResponse,
                        style: const TextStyle(fontSize: 15),
                      ),
                      if (state.requestResponseTime.isNotEmpty) const Divider(height: 24),
                      if (state.requestResponseTime.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              state.requestResponseTime,
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.responderStatus != curr.responderStatus;
        var c3 = prev.isResponderActive != curr.isResponderActive;
        var c4 = prev.lastRequestReceived != curr.lastRequestReceived;
        var c5 = prev.lastRequestTime != curr.lastRequestTime;
        return c1 || c2 || c3 || c4 || c5;
      },
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
                          onPressed: state.isConnected && !state.isResponderActive ? _startResponder : null,
                          child: const Text("Start", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isResponderActive ? _stopResponder : null,
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
                    color: state.isResponderActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isResponderActive ? Colors.green.shade300 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isResponderActive ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: state.isResponderActive ? Colors.green.shade700 : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Status: ${state.responderStatus}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: state.isResponderActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.lastRequestReceived != "No requests yet") const Divider(height: 24),
                      if (state.lastRequestReceived != "No requests yet")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Last request:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.lastRequestReceived,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  state.lastRequestTime,
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.publishStatus != curr.publishStatus;
        return c1 || c2;
      },
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
                    "Status: ${state.publishStatus}",
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.subscriberStatus != curr.subscriberStatus;
        var c3 = prev.isSubscriberActive != curr.isSubscriberActive;
        var c4 = prev.lastPublishMsgReceived != curr.lastPublishMsgReceived;
        var c5 = prev.lastPublishMsgTime != curr.lastPublishMsgTime;
        return c1 || c2 || c3 || c4 || c5;
      },
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
                          onPressed: state.isConnected && !state.isSubscriberActive ? _startSubscriber : null,
                          child: const Text("Start", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.isSubscriberActive ? _stopSubscriber : null,
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
                    color: state.isSubscriberActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isSubscriberActive ? Colors.green.shade300 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.isSubscriberActive ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: state.isSubscriberActive ? Colors.green.shade700 : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Status: ${state.subscriberStatus}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: state.isSubscriberActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.lastPublishMsgReceived != "No messages yet" && state.lastPublishMsgReceived != "No requests yet")
                        const Divider(height: 24),
                      if (state.lastPublishMsgReceived != "No messages yet" && state.lastPublishMsgReceived != "No requests yet")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Last message:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.lastPublishMsgReceived,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  state.lastPublishMsgTime,
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
      buildWhen: (prev, curr) {
        var c1 = prev.isConnected != curr.isConnected;
        var c2 = prev.kvStatus != curr.kvStatus;
        var c3 = prev.kvLastOperationTime != curr.kvLastOperationTime;
        return c1 || c2 || c3;
      },
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
                        "Status: ${state.kvStatus}",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (state.kvLastOperationTime.isNotEmpty) const Divider(height: 24),
                      if (state.kvLastOperationTime.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              state.kvLastOperationTime,
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
          cubit.updateConnectionStatus(true);
          cubit.updateConnectionStatusText("Connected");
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorString) {
        setState(() {
          cubit.updateConnectionStatus(false);
          cubit.updateConnectionStatusText("Not Connected - $errorString");
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
          cubit.updateConnectionStatus(false);
          cubit.updateConnectionStatusText("Disconnected");
          cubit.updateResponderActive(false);
          cubit.updateSubscriberActive(false);
          cubit.updateResponderStatus("Responder not active");
          cubit.updateSubscriberStatus("Subscriber not active");
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateConnectionStatusText("Disconnect error: $errorMessage");
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
          cubit.updatePublishStatus("Message published successfully at ${_formatTimestamp()}");
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updatePublishStatus("Publish error: $errorMessage");
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
          cubit.updateRequestResponse(successMessage);
          cubit.updateRequestResponseTime(_formatTimestamp());
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateRequestResponse("Request error: $errorMessage");
          cubit.updateRequestResponseTime(_formatTimestamp());
          cubit.updateLoadingStatus(false);
        });
      },
    );
  }

  // RESPONDER FUNCTIONS
  void _startResponder() {
    cubit.natsController.setupResponder(
      subject: cubit.controllers.responderSubjectController.text,
      responderId: cubit.state.responderID,
      processRequest: (requestMessage) async {
        setState(() {
          cubit.updateLastRequestReceived(requestMessage);
          cubit.updateLastRequestTime(_formatTimestamp());
        });
        return cubit.controllers.responderReplyController.text;
      },
      onSuccess: (isSuccess) {
        setState(() {
          cubit.updateResponderStatus("Responder active");
          cubit.updateResponderActive(true);
        });
      },
      onError: (errorMessage) {
        setState(() {
          cubit.updateResponderStatus("Responder error: $errorMessage");
        });
      },
    );
  }

  void _stopResponder() {
    cubit.natsController.unsubscribe(
      subscriptionId: cubit.state.responderID,
      onSuccess: (isSuccess) {
        setState(() {
          cubit.updateResponderStatus("Responder not active");
          cubit.updateResponderActive(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateResponderStatus("Stop responder error: $errorMessage");
        });
      },
    );
  }

  // SUBSCRIBER FUNCTIONS
  void _startSubscriber() {
    cubit.natsController.subscribe(
      subject: cubit.controllers.subscribeSubjectController.text,
      subscriptionId: cubit.state.subscriberID,
      maxMessages: 1000,
      onMessage: (topic, message) {
        setState(() {
          cubit.updateLastPublishMsgReceived(message);
          cubit.updateLastPublishMsgTime(_formatTimestamp());
        });
      },
      onSuccess: (isSuccess) {
        setState(() {
          cubit.updateSubscriberStatus("Subscriber active");
          cubit.updateSubscriberActive(true);
        });
      },
      onError: (errorMessage) {
        setState(() {
          cubit.updateSubscriberStatus("Subscriber error: $errorMessage");
          cubit.updateSubscriberActive(false);
        });
      },
      onDone: () {
        setState(() {
          cubit.updateSubscriberStatus("Subscription completed");
          cubit.updateSubscriberActive(false);
        });
      },
    );
  }

  void _stopSubscriber() {
    cubit.natsController.unsubscribe(
      subscriptionId: cubit.state.subscriberID,
      onSuccess: (isSuccess) {
        setState(() {
          cubit.updateSubscriberStatus("Subscriber not active");
          cubit.updateSubscriberActive(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateSubscriberStatus("Stop subscriber error: $errorMessage");
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
          cubit.updateKvStatus("Value stored successfully");
          cubit.updateKvLastOperationTime(_formatTimestamp());
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateKvStatus("Put error: $errorMessage");
          cubit.updateKvLastOperationTime(_formatTimestamp());
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
          cubit.updateKvStatus("Value retrieved successfully");
          cubit.updateKvLastOperationTime(_formatTimestamp());
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateKvStatus("Get error: $errorMessage");
          cubit.updateKvLastOperationTime(_formatTimestamp());
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
          cubit.updateKvStatus("Key deleted successfully");
          cubit.updateKvLastOperationTime(_formatTimestamp());
          cubit.updateLoadingStatus(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          cubit.updateKvStatus("Delete error: $errorMessage");
          cubit.updateKvLastOperationTime(_formatTimestamp());
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
