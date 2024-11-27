import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/dependency_injection.dart';
import 'package:frontend/presentation/app.dart';

void main() async {
  await DependencyInjection.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DependencyInjection.providers,
      child: const App(),
    );
  }
}
