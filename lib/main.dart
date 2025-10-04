import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:mission_up/routes/routes.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/utils/date_formatter.dart'; // contiene TimeService
import 'package:mission_up/views/loading.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa servicio de tiempo
  final timeService = TimeService();
  await timeService.init();

  // Crea instancias que quieres preservar entre hot reloads
  final authService = AuthService();
  final alumnoProvider = AlumnoProvider(authService);
  final actividadesProvider = ActividadesProvider(authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TimeService>.value(value: timeService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        // Si AlumnoProvider depende de AuthService pero quieres manejar su actualización:
        ChangeNotifierProvider<AlumnoProvider>.value(value: alumnoProvider),
        ChangeNotifierProvider<ActividadesProvider>.value(
            value: actividadesProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MissionUp',
      debugShowCheckedModeBanner: false,
      home: AuthWrapperScreen(),
      onGenerateRoute: generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'PE'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
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
