import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'presentation/screens/main_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/layer_provider.dart';
import 'presentation/state/paint_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
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

      /// 🔥 DÙNG STREAMBUILDER ĐỂ NGHE AUTH TRỰC TIẾP
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // Đang kiểm tra trạng thái
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Nếu chưa đăng nhập -> Login
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // Nếu đã đăng nhập -> Main
          return const MainScreen();
        },
      ),
    );
  }
}
