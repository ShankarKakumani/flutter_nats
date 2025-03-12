import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nats/flutter_nats.dart';
import 'package:intl/intl.dart';

class NatsPlaygroundPage extends StatefulWidget {
  const NatsPlaygroundPage({super.key});

  @override
  NatsPlaygroundPageState createState() => NatsPlaygroundPageState();
}

class NatsPlaygroundPageState extends State<NatsPlaygroundPage> {
  late NatsController _natsController;
  bool _isLoading = false;

  // Connection Section
  final TextEditingController _hostController = TextEditingController(text: "127.0.0.1");
  final TextEditingController _portController = TextEditingController(text: "4222");

  String _connectionStatus = "Not connected";
  bool _isConnected = false;

  // Publish Section
  final TextEditingController _publishSubjectController = TextEditingController(text: "topic_publish");
  final TextEditingController _publishMessageController = TextEditingController(text: "Hello from Publisher!");
  String _publishStatus = "No message published";

  // Request Section
  final TextEditingController _requestSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController _requestMessageController = TextEditingController(text: "Hello, NATS!");
  String _requestResponse = "No request sent";
  String _requestResponseTime = "";

  // Responder Section
  final TextEditingController _responderSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController _responderReplyController = TextEditingController(text: "Hello from Flutter!");
  String _responderStatus = "Responder not active";
  bool _isResponderActive = false;
  String _lastRequestReceived = "No requests yet";
  String _lastRequestTime = "";
  final String _responderID = "responder-123";

  // Subscriber Section
  final TextEditingController _subscribeSubjectController = TextEditingController(text: "topic_publish");
  String _subscriberStatus = "Subscriber not active";
  bool _isSubscriberActive = false;
  String _lastPublishMsgReceived = "No messages yet";
  String _lastPublishMsgTime = "";
  final String _subscriberID = "subscriber-123";

  // Key-Value Section
  final TextEditingController _kvBucketController = TextEditingController(text: "my-bucket");
  final TextEditingController _kvKeyController = TextEditingController(text: "my-key");
  final TextEditingController _kvValueController = TextEditingController(text: "Hello KV Store!");
  String _kvStatus = "No KV operations performed";
  String _kvLastOperationTime = "";

  @override
  void initState() {
    super.initState();
    _natsController = NatsController(
      config: NatsConfig(
        host: _hostController.text,
        port: int.tryParse(_portController.text) ?? 4222,
      ),
    );
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    return formatter.format(now);
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // UI SECTIONS

  Widget _buildConnectionSection() {
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
                    controller: _hostController,
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
                    controller: _portController,
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
                    onPressed: !_isConnected ? _connect : null,
                    child: const Text("Connect", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _disconnect : null,
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
                color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isConnected ? Colors.green.shade300 : Colors.red.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Status: $_connectionStatus",
                      style: TextStyle(
                        color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
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
  }

  Widget _buildRequestSection() {
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
              controller: _requestSubjectController,
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
              controller: _requestMessageController,
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
                onPressed: _isConnected ? _sendRequest : null,
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
  }

  Widget _buildResponderSection() {
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
              controller: _responderSubjectController,
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
              controller: _responderReplyController,
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
                      onPressed: _isConnected && !_isResponderActive ? _startResponder : null,
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
  }

  Widget _buildPublishSection() {
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
              controller: _publishSubjectController,
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
              controller: _publishMessageController,
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
                onPressed: _isConnected ? _publish : null,
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
  }

  Widget _buildSubscribeSection() {
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
              controller: _subscribeSubjectController,
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
                      onPressed: _isConnected && !_isSubscriberActive ? _startSubscriber : null,
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
  }

  Widget _buildKeyValueSection() {
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
              controller: _kvBucketController,
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
              controller: _kvKeyController,
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
              controller: _kvValueController,
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
                      onPressed: _isConnected ? _putValue : null,
                      child: const Text("Put", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isConnected ? _getValue : null,
                      child: const Text("Get", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isConnected ? _deleteValue : null,
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
  }

  // CONNECTION FUNCTIONS
  void _connect() {
    _setLoading(true);

    final host = _hostController.text;
    final port = int.tryParse(_portController.text) ?? 4222;

    // Create a new NatsConfig
    final config = NatsConfig(
      host: host,
      port: port,
    );

    // Update the controller if config changed
    if (_natsController.config.host != config.host || _natsController.config.port != config.port) {
      _natsController = NatsController(config: config);
    }

    _natsController.connect(
      onSuccess: (isConnected) {
        setState(() {
          _connectionStatus = "Connected";
          _isConnected = true;
          _setLoading(false);
        });
      },
      onFailure: (errorString) {
        setState(() {
          _connectionStatus = "Not Connected - $errorString";
          _isConnected = false;
          _setLoading(false);
        });
      },
    );
  }

  void _disconnect() {
    _setLoading(true);
    _natsController.disconnect(
      onSuccess: (isSuccess) {
        setState(() {
          _connectionStatus = "Disconnected";
          _isConnected = false;
          _isResponderActive = false;
          _isSubscriberActive = false;
          _responderStatus = "Responder not active";
          _subscriberStatus = "Subscriber not active";
          _setLoading(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _connectionStatus = "Disconnect error: $errorMessage";
          _setLoading(false);
        });
      },
    );
  }

  // PUBLISH FUNCTIONS
  void _publish() {
    _natsController.publish(
      subject: _publishSubjectController.text,
      payload: _publishMessageController.text,
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
    _setLoading(true);
    _natsController.sendRequestWithCallbacks(
      subject: _requestSubjectController.text,
      payload: _requestMessageController.text,
      timeoutMs: 5000,
      onSuccess: (successMessage) {
        setState(() {
          _requestResponse = successMessage;
          _requestResponseTime = _formatTimestamp();
          _setLoading(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _requestResponse = "Request error: $errorMessage";
          _requestResponseTime = _formatTimestamp();
          _setLoading(false);
        });
      },
    );
  }

  // RESPONDER FUNCTIONS
  void _startResponder() {
    _natsController.setupResponder(
      subject: _responderSubjectController.text,
      responderId: _responderID,
      processRequest: (requestMessage) async {
        setState(() {
          _lastRequestReceived = requestMessage;
          _lastRequestTime = _formatTimestamp();
        });
        return _responderReplyController.text;
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
    _natsController.unsubscribe(
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
    _natsController.subscribe(
      subject: _subscribeSubjectController.text,
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
    _natsController.unsubscribe(
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
    _setLoading(true);
    _natsController.kvPut(
      bucketName: _kvBucketController.text,
      key: _kvKeyController.text,
      value: _kvValueController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _kvStatus = "Value stored successfully";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Put error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
    );
  }

  void _getValue() {
    _setLoading(true);
    _natsController.kvGet(
      bucketName: _kvBucketController.text,
      key: _kvKeyController.text,
      onSuccess: (value) {
        setState(() {
          _kvValueController.text = value;
          _kvStatus = "Value retrieved successfully";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Get error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
    );
  }

  void _deleteValue() {
    _setLoading(true);
    _natsController.kvDelete(
      bucketName: _kvBucketController.text,
      key: _kvKeyController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _kvStatus = "Key deleted successfully";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Delete error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
          _setLoading(false);
        });
      },
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _requestSubjectController.dispose();
    _requestMessageController.dispose();
    _publishSubjectController.dispose();
    _publishMessageController.dispose();
    _responderSubjectController.dispose();
    _responderReplyController.dispose();
    _subscribeSubjectController.dispose();
    _kvBucketController.dispose();
    _kvKeyController.dispose();
    _kvValueController.dispose();
    super.dispose();
  }
}
