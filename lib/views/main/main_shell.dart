// lib/views/main/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/models/actividad.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/views/main/activities/activities.dart';
import 'package:mission_up/views/main/activities/activities_picker_screen.dart';
import 'package:mission_up/views/main/activities/activity_form.dart';
import 'package:mission_up/views/main/assignments_screen.dart';
import 'package:mission_up/views/main/home.dart';
import 'package:mission_up/views/main/profile.dart';
import 'package:mission_up/views/main/students_picker.dart';
import 'package:provider/provider.dart';

// 👇 NUEVO: importa tu pantalla de asignaciones
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos leer el authService aquí, el ProxyProvider lo hará por nosotros.

    return const _MainShellView();
  }
}

// --- Widget Interno que Maneja la Vista y la Navegación ---
class _MainShellView extends StatefulWidget {
  // ✅ 'initialIndex' eliminado. Ya no es necesario.
  const _MainShellView();

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
  late int _index;
  late List<GlobalKey<NavigatorState>> _keys;

  @override
  void initState() {
    super.initState();
    _index = 0; // ✅ Siempre empezamos en la primera pestaña (índice 0).
    _keys = [];
  }

  // ... (los métodos _noAnimRoute, _onWillPop, _onTap se mantienen igual) ...
  Route _noAnimRoute(Widget page, RouteSettings s) {
    return PageRouteBuilder(
      settings: s,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }

  Future<bool> _onWillPop() async {
    final nav = _keys[_index].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  void _onTap(int i) {
    if (i == _index) {
      _keys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _index = i);
    }
  } // ...

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isAdmin = authService.currentUser?.isAdmin ?? false;
    final tabsCount = isAdmin ? 4 : 3;

    if (_keys.length != tabsCount) {
      _keys = List.generate(tabsCount, (_) => GlobalKey<NavigatorState>());
      if (_index >= tabsCount) {
        _index = 0;
      }
    }

    // ✅ Rutas simplificadas. Ya no se usan los ...ProviderScreen
    final tabsRoutes = <Map<String, WidgetBuilder>>[
      {
        '/': (_) => const HomeDashboardScreen(),
        // La navegación para asignar ahora vive dentro de la pestaña Home
        'students/select': (_) => const StudentsSelectScreen(),
      },
      {
        '/': (_) => const ActivitiesScreen(),
      },
      if (isAdmin)
        {
          // Esta pestaña puede ser la de "Asignaciones" o un resumen
          '/': (_) => const StudentsSelectScreen(),
          '/activities': (_) => const ActivitiesPickerScreen()
        },
      {
        '/': (_) => const ProfileScreen(),
      },
    ];

    if (_index >= tabsRoutes.length) _index = 0;

    // ✅ onGenerateRoute ahora es más simple
    Widget _tabNavigator({
      required int index,
      required Map<String, WidgetBuilder> routes,
    }) {
      return Offstage(
        offstage: _index != index,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _GradientBg(),
            Navigator(
              key: _keys[index],
              initialRoute: '/',
              onGenerateRoute: (settings) {
                // Para editar, solo pasamos la actividad.
                if (settings.name == 'activity/edit') {
                  print("settings.arguments es ${settings.arguments}");
                  final actividad = (settings.arguments as Map)["actividad"];

                  return _noAnimRoute(
                    ActivityFormScreen(
                        isEdit: true, actividad: actividad as Actividad),
                    settings,
                  );
                }
                // Para crear, no pasamos argumentos.
                if (settings.name == 'activity/create') {
                  return _noAnimRoute(
                    const ActivityFormScreen(isEdit: false),
                    settings,
                  );
                }

                final builder = routes[settings.name] ?? routes['/']!;
                return _noAnimRoute(builder(context), settings);
              },
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBody: true,
          body: Stack(
            children: List.generate(
              tabsRoutes.length,
              (i) => _tabNavigator(index: i, routes: tabsRoutes[i]),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _index,
            isAdmin: isAdmin,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}

class _GradientBg extends StatelessWidget {
  const _GradientBg();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1C), Color(0xFF040404)],
        ),
      ),
    );
  }
}

/// ---- Bottom bar
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Inicio',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/task.svg',
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
        ),
        activeIcon: SvgPicture.asset(
          'assets/icons/task.svg',
          width: 22,
          height: 22,
          colorFilter:
              const ColorFilter.mode(AppTheme.coinsColor, BlendMode.srcIn),
        ),
        label: isAdmin ? 'Actividades' : 'Recompensas',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in_outlined),
          activeIcon: Icon(Icons.assignment_turned_in_rounded),
          label: 'Asignar',
        ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/profile.svg',
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
        ),
        activeIcon: SvgPicture.asset(
          'assets/icons/profile.svg',
          width: 22,
          height: 22,
          colorFilter:
              const ColorFilter.mode(AppTheme.coinsColor, BlendMode.srcIn),
        ),
        label: 'Perfil',
      ),
    ];

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            canvasColor: AppTheme.blackLight,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.blackLight,
            currentIndex: currentIndex,
            selectedItemColor: AppTheme.coinsColor,
            unselectedItemColor: Colors.white70,
            items: items,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
