import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/paint_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    "/login": (context) => const LoginScreen(),
    "/main": (context) => const MainScreen(),
    "/profile": (context) => const ProfileScreen(),
    "/paint": (context) => const PaintScreen(),
  };
}
