import 'package:flutter/material.dart';
import 'package:flutter_nats/src/rust/api/rust.dart';
import 'package:flutter_nats/src/rust/api/rust_manager.dart' as nats_manager;
import 'package:flutter_nats/src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Connection Section
  final TextEditingController _endpointController = TextEditingController(text: "nats://127.0.0.1:4222");
  String _connectionStatus = "Not connected";
  bool _isConnected = false;

  // Request Section
  final TextEditingController _requestSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController _requestMessageController = TextEditingController(text: "Hello, NATS!");
  String _requestResponse = "No request sent";

  // Responder Section
  final TextEditingController _responderSubjectController = TextEditingController(text: "my_subject");
  final TextEditingController _responderReplyController = TextEditingController(text: "Hello from Flutter!");
  String _responderStatus = "Responder not active";
  bool _isResponderActive = false;

  @override
  void initState() {
    super.initState();
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
        });
      },
      onFailure: (errorMessage) {
        setState(() {
          _connectionStatus = "Disconnect error: $errorMessage";
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
        });
      },
      onSuccess: (successMessage) {
        setState(() {
          _requestResponse = successMessage;
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
        _responderStatus = "Stop responder error: $errorMessage";
      },
    );
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _requestSubjectController.dispose();
    _requestMessageController.dispose();
    _responderSubjectController.dispose();
    _responderReplyController.dispose();
    super.dispose();
  }
}
