import 'package:example/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nats/flutter_nats.dart';

import 'common/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencyInjection();
  await RustLib.init();
  runApp(const MyApp());
}
