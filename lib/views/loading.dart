import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthWrapperScreen extends StatefulWidget {
  const AuthWrapperScreen({Key? key}) : super(key: key);

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Usamos didChangeDependencies para escuchar cambios en el Provider.
    // Es una forma segura de reaccionar y navegar.
    final authService = Provider.of<AuthService>(context);

    // addPostFrameCallback asegura que la navegación ocurra después del build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (authService.authStatus) {
        case AuthStatus.Unauthenticated:
          // ✅ En lugar de devolver un widget, navegamos a la RUTA '/intro'.
          Navigator.pushNamedAndRemoveUntil(
              context, '/intro', (route) => false);
          break;
        case AuthStatus.Authenticated:
          // ✅ Navegamos a la RUTA '/main'.
          if (!authService.currentUser!.isAdmin &&
              !authService.currentUser!.isAccepted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/pending",
              (route) => false,
            );
            break;
          }
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false,
              arguments: {
                'tab': 0,
              });
          break;
        case AuthStatus.Checking:
          // No hacemos nada y nos quedamos en la pantalla de carga.
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // La única responsabilidad de este widget es mostrar la pantalla de carga.
    // La lógica para decidir a dónde ir está en didChangeDependencies.
    return const Scaffold(
      // Puedes hacer el fondo transparente si quieres que se vea el degradado global
      // backgroundColor: Colors.transparent,
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 10,
        ),
      ),
    );
  }
}
