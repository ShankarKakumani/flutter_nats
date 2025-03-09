import 'package:flutter/material.dart';
import 'package:flutter_nats/src/rust/api/nats_manager.dart' as nats_manager;
import 'package:flutter_nats/src/rust/frb_generated.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Connection Section
  final TextEditingController _endpointController = TextEditingController(text: "nats://127.0.0.1:4222");
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

  String _lastPublishMsgReceived = "No requests yet";
  String _lastPublishMsgTime = "";

  // Subscriber Section
  final TextEditingController _subscribeSubjectController = TextEditingController(text: "topic_publish");
  String _subscriberStatus = "Responder not active";
  bool _isSubscriberActive = false;

  // Add these variables to your MyAppState class
  // Key-Value Section
  final TextEditingController _kvBucketController = TextEditingController(text: "my-bucket");
  final TextEditingController _kvKeyController = TextEditingController(text: "my-key");
  final TextEditingController _kvValueController = TextEditingController(text: "Hello KV Store!");
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
    return MaterialApp(
      title: "NATS Playground",
      home: Scaffold(
        appBar: AppBar(title: const Text("NATS Playground")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Section
              const Text("Connection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _endpointController,
                decoration: const InputDecoration(labelText: "Endpoint"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: !_isConnected ? _connect : null,
                    child: const Text("Connect"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isConnected ? _disconnect : null,
                    child: const Text("Disconnect"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Status: $_connectionStatus"),
              const SizedBox(height: 32),

              // Request Section
              const Text("Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _requestSubjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _requestMessageController,
                decoration: const InputDecoration(labelText: "Message"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isConnected ? _sendRequest : null,
                child: const Text("Send Request"),
              ),
              const SizedBox(height: 12),
              Text("Response: $_requestResponse"),
              if (_requestResponseTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text("Time: $_requestResponseTime", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ),
              const SizedBox(height: 32),

              // Responder Section
              const Text("Responder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _responderSubjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _responderReplyController,
                decoration: const InputDecoration(labelText: "Reply Message"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isConnected && !_isResponderActive ? _startResponder : null,
                    child: const Text("Start Responder"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isResponderActive ? _stopResponder : null,
                    child: const Text("Stop Responder"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Responder Status: $_responderStatus"),
              if (_lastRequestReceived != "No requests yet")
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last request: $_lastRequestReceived"),
                      Text("Time: $_lastRequestTime", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              // Publish Section
              const Text("Publish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _publishSubjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _publishMessageController,
                decoration: const InputDecoration(labelText: "Message"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isConnected ? _publish : null,
                child: const Text("Publish Message"),
              ),
              const SizedBox(height: 12),
              Text("Status: $_publishStatus"),
              const SizedBox(height: 32),

              // Subscribe Section
              const Text("Subscribe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _subscribeSubjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isConnected && !_isSubscriberActive ? _startSubscriber : null,
                    child: const Text("Start Subscribing"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubscriberActive ? _stopSubscriber : null,
                    child: const Text("Stop Subscribing"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Subscriber Status: $_subscriberStatus"),
              if (_lastPublishMsgReceived != "No publish messages yet")
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last Publish Msg: $_lastPublishMsgReceived"),
                      Text("Time: $_lastPublishMsgTime", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              //KeyValue
              keyValueSection(),
            ],
          ),
        ),
      ),
    );
  }


  Widget keyValueSection() {
    return Column(
      children: [
        // Key-Value Section
        const Text("Key-Value Store", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _kvBucketController,
          decoration: const InputDecoration(labelText: "Bucket"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kvKeyController,
          decoration: const InputDecoration(labelText: "Key"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kvValueController,
          decoration: const InputDecoration(labelText: "Value"),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isConnected ? _putValue : null,
              child: const Text("Put Value"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isConnected ? _getValue : null,
              child: const Text("Get Value"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text("Status: $_kvStatus"),
        if (_kvLastOperationTime.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("Time: $_kvLastOperationTime",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
  // Connect to NATS.
  void _connect() async {
    nats_manager.connectToNats(
      endPoint: _endpointController.text,
      onSuccess: (isConnected) {
        setState(() {
          _connectionStatus = "Connected";
          _isConnected = true;
        });
      },
      onFailure: (errorString) {
        setState(() {
          _connectionStatus = "Not Connected - $errorString";
          _isConnected = false;
        });
      },
    );
  }

  // Disconnect from NATS.
  void _disconnect() {
    nats_manager.disconnectFromNats(
      onSuccess: (isSuccess) {
        setState(() {
          _connectionStatus = "Disconnected";
          _isConnected = false;
          _isResponderActive = false;
          _responderStatus = "Responder not active";
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _connectionStatus = "Disconnect error: $errorMessage";
        });
      },
    );
  }

  // Publish a message
  void _publish() {
    nats_manager.publish(
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

  // Send a request.
  void _sendRequest() {
    nats_manager.sendRequestWithCallbacks(
      subject: _requestSubjectController.text,
      payload: _requestMessageController.text,
      timeoutMs: BigInt.from(5000),
      onFailure: (errorMessage) {
        setState(() {
          _requestResponse = "Request error: $errorMessage";
          _requestResponseTime = _formatTimestamp();
        });
      },
      onSuccess: (successMessage) {
        setState(() {
          _requestResponse = successMessage;
          _requestResponseTime = _formatTimestamp();
        });
      },
    );
  }

  // Start the responder.
  void _startResponder() {
    nats_manager.setupResponder(
      subject: _responderSubjectController.text,
      responderId: "12345678",
      processRequest: (requestMessage) {
        setState(() {
          _lastRequestReceived = requestMessage;
          _lastRequestTime = _formatTimestamp();
        });
        return _responderReplyController.text;
      },
      onSuccess: (isSuccess) {
        setState(() {
          _responderStatus = "Responder started";
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

  // Stop the responder.
  void _stopResponder() {
    nats_manager.unsubscribe(
      subscriptionId: "12345678",
      onSuccess: (isSuccess) {
        setState(() {
          _responderStatus = "Responder is not Running";
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

  void _startSubscriber() {
    nats_manager.subscribe(
      subject: _subscribeSubjectController.text,
      subscriptionId: "sub123",
      maxMessages: 1000,
      onMessage: (topic, message) {
        setState(() {
          _lastPublishMsgReceived = message;
          _lastPublishMsgTime = _formatTimestamp();
        });
        debugPrint(
          "onMessage - message : $message --- topic : $topic",
        );
      },
      onSuccess: (isSuccess) {
        debugPrint("subscribe - onSuccess : $isSuccess");
        setState(() {
          _subscriberStatus = "Subscriber started";
          _isSubscriberActive = true;
        });
      },
      onError: (errorMessage) {
        setState(() {
          _subscriberStatus = "Subscriber error: $errorMessage";
          _isSubscriberActive = false;
        });
        debugPrint("subscribe - onError : $errorMessage");
      },
      onDone: () {
        debugPrint("subscribe - onDone");
      },
    );
  }

  // Stop the subscriber.
  void _stopSubscriber() {
    nats_manager.unsubscribe(
      subscriptionId: "sub123",
      onSuccess: (isSuccess) {
        setState(() {
          _subscriberStatus = "Subscriber is not Running";
          _isSubscriberActive = false;
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _subscriberStatus = "Stop Subscriber error: $errorMessage";
        });
      },
    );
  }

  // Put a value in the key-value store
  void _putValue() {
    nats_manager.kvPut(
      bucketName: _kvBucketController.text,
      key: _kvKeyController.text,
      value: _kvValueController.text,
      onSuccess: (isSuccess) {
        setState(() {
          _kvStatus = "Value stored successfully";
          _kvLastOperationTime = _formatTimestamp();
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Put error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
        });
      },
    );
  }

// Get a value from the key-value store
  void _getValue() {
    nats_manager.kvGet(
      bucketName: _kvBucketController.text,
      key: _kvKeyController.text,
      onSuccess: (value) {
        setState(() {
          _kvValueController.text = value;
          _kvStatus = "Value retrieved successfully";
          _kvLastOperationTime = _formatTimestamp();
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _kvStatus = "Get error: $errorMessage";
          _kvLastOperationTime = _formatTimestamp();
        });
      },
    );
  }

  @override
  void dispose() {
    _endpointController.dispose();
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

