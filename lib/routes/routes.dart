import 'package:flutter/material.dart';
import 'package:mission_up/views/auth/student_screen.dart';
import 'package:mission_up/views/auth/login_screen.dart';
import 'package:mission_up/views/auth/register_screen.dart';
import 'package:mission_up/views/intro/intro_o.dart';
import 'package:mission_up/views/loading.dart';
import 'package:mission_up/views/main/activities/activity_form.dart';
import 'package:mission_up/views/main/home.dart';
import 'package:mission_up/views/main/main_shell.dart';
import 'package:mission_up/views/main/pending/pending_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>? ?? {};

  debugPrint('generateRoute -> ${settings.name}');
  switch (settings.name) {
    case '/intro':
      return _fadeRoute(const IntroductionScreen(), settings);
    case '/guest':
      return _fadeRoute(const InviteRegisterScreen(), settings);
    case '/login':
      return _fadeRoute(const LoginScreen(), settings);
    case '/register':
      return _fadeRoute(const RegisterScreen(), settings);
    case '/loading':
      return _fadeRoute(const AuthWrapperScreen(), settings);
    case '/pending':
      return _fadeRoute(const PendingApprovalScreen(), settings);
    case '/main':
      {
        final tab = args?['tab'] as int? ?? 0;

        return MaterialPageRoute(
          builder: (_) => MainShell(),
          settings: settings,
        );
      }
    case 'activity_form':
      return _fadeRoute(const ActivityFormScreen(), settings);

    default:
      return _fadeRoute(const IntroductionScreen(), settings);
  }
}

PageRoute _fadeRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1C), Color(0xFF040404)],
              ),
            ),
          ),
          FadeTransition(opacity: curved, child: child),
        ],
      );
    },
  );
}
