import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/main_screen.dart';
import 'firebase_options.dart';
import 'presentation/state/layer_provider.dart';
import 'presentation/state/paint_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LayerProvider()),
        ChangeNotifierProvider(create: (_) => PaintProvider()),
      ],
      child: const PaintingApp(),
    ),
  );
}

class PaintingApp extends StatelessWidget {
  const PaintingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
