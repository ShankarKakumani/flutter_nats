import 'package:flutter/material.dart';
import 'package:flutter_nats/src/rust/api/rust.dart';
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
  void _connect() {
    try {
      final result = connectSync(natsUrl: _endpointController.text);
      setState(() {
        _connectionStatus = result;
        _isConnected = true;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = "Connection error: $e";
      });
    }
  }

  // Disconnect from NATS.
  void _disconnect() {
    try {
      final result = disconnectSync();
      setState(() {
        _connectionStatus = result;
        _isConnected = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = "Disconnect error: $e";
      });
    }
  }

  // Send a request.
  void _sendRequest() {
    try {
      final result = sendRequestSync(
        natsUrl: _endpointController.text,
        subject: _requestSubjectController.text,
        message: _requestMessageController.text,
      );
      setState(() {
        _requestResponse = result;
      });
    } catch (e) {
      setState(() {
        _requestResponse = "Request error: $e";
      });
    }
  }

  // Start the responder.
  void _startResponder() {
    try {
      final result = startResponderSync(
        natsUrl: _endpointController.text,
        subject: _responderSubjectController.text,
        replyMessage: _responderReplyController.text,
      );
      setState(() {
        _responderStatus = result;
        _isResponderActive = true;
      });
    } catch (e) {
      setState(() {
        _responderStatus = "Responder error: $e";
      });
    }
  }

  // Stop the responder.
  void _stopResponder() {
    try {
      final result = stopResponderSync();
      setState(() {
        _responderStatus = result;
        _isResponderActive = false;
      });
    } catch (e) {
      setState(() {
        _responderStatus = "Stop responder error: $e";
      });
    }
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
