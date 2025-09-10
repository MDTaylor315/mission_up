// lib/views/main/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/views/main/activities.dart';
import 'package:mission_up/views/main/activities_picker.dart';
import 'package:mission_up/views/main/activity_form.dart';
import 'package:mission_up/views/main/assignments_screen.dart';
import 'package:mission_up/views/main/home.dart';
import 'package:mission_up/views/main/profile.dart';
import 'package:mission_up/views/main/students_picker.dart';
// 👇 NUEVO: importa tu pantalla de asignaciones

class MainShell extends StatefulWidget {
  final bool isAdmin;
  final int initialIndex;

  const MainShell({
    super.key,
    this.isAdmin = false,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  late List<GlobalKey<NavigatorState>> _keys; // 👈 ahora dinámico

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _keys = List.generate(_tabsCount, (_) => GlobalKey<NavigatorState>()); // 👈
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia isAdmin (o potencialmente el número de tabs), re-crea llaves y ajusta índice
    if (oldWidget.isAdmin != widget.isAdmin) {
      final newLen = _tabsCount;
      _keys = List.generate(newLen, (_) => GlobalKey<NavigatorState>());
      if (_index >= newLen) _index = 0;
      setState(() {}); // fuerza rebuild con nueva cantidad de tabs
    }
  }

  int get _tabsCount => widget.isAdmin ? 4 : 3; // 👈 con Asignar para admin

  Route _noAnimRoute(Widget page, RouteSettings s) {
    return PageRouteBuilder(
      settings: s,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }

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
              final builder = routes[settings.name] ?? routes['/']!;
              return _noAnimRoute(builder(context), settings);
            },
          ),
        ],
      ),
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
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Definimos las rutas por pestaña de forma dinámica
    final tabsRoutes = <Map<String, WidgetBuilder>>[
      {
        '/': (_) => HomeDashboardScreen(isAdmin: widget.isAdmin),
      },
      {
        '/': (_) => ActivitiesScreen(isAdmin: widget.isAdmin),
        'activity/create': (_) => const ActivityFormScreen(),
        'activity/edit': (_) => const ActivityFormScreen(isEdit: true),
      },
      if (widget.isAdmin)
        {
          '/': (_) => const AssignmentsScreen(), // 👈 Nueva pestaña "Asignar"
          // Si necesitas rutas internas de asignaciones, añádelas aquí
          'students/select': (_) => const StudentsSelectScreen(),
          'activities/picker': (_) => const ActivitiesPickerScreen(),
        },
      {
        '/': (_) => ProfileScreen(),
      },
    ];

    // Seguridad por si el índice queda fuera de rango
    if (_index >= tabsRoutes.length) _index = 0;

    return WillPopScope(
      onWillPop: _onWillPop,
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
          isAdmin: widget.isAdmin,
          onTap: _onTap,
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
