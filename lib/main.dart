import 'package:flutter/material.dart';
import 'package:mission_up/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MissionUp',
      debugShowCheckedModeBanner: false,

      // Navegación por rutas
      initialRoute: '/intro',
      onGenerateRoute: generateRoute,

      // Tema
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
        scaffoldBackgroundColor:
            Colors.transparent, // los Scaffold no tapan el fondo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      // Degradado global (aplica a TODAS las rutas)
      builder: (context, child) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1C), Color(0xFF040404)],
          ),
        ),
        child: child,
      ),
    );
  }
}
