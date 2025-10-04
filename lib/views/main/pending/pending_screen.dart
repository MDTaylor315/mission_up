import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.read para llamar a una función, es más eficiente aquí.
    final authService = context.read<AuthService>();

    return Stack(
      children: [
        // Usamos el mismo fondo degradado para mantener la consistencia
        const _GradientBg(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono principal para dar contexto visual
                  Icon(
                    authService.currentUser!.isRejected
                        ? Icons.block
                        : Icons.hourglass_empty_rounded,
                    color: AppTheme.primaryColor,
                    size: 80,
                  ),
                  const SizedBox(height: 24),

                  // Título principal, grande y claro
                  Text(
                    authService.currentUser!.isRejected
                        ? 'Solicitud Rechazada'
                        : 'Esperando Aprobación',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Mensaje descriptivo
                  Text(
                    authService.currentUser!.isRejected
                        ? 'El tutor ha rechazado tu solicitud, ¿deseas solicitar acceso a la familia nuevamente?'
                        : 'Tu tutor necesita confirmar tu solicitud para unirse a la familia. Por favor, avísale para que pueda aceptarte.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          height: 1.5, // Mejora la legibilidad
                        ),
                  ),
                  const SizedBox(height: 48),
                  if (authService.currentUser!.isRejected)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.replay_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Solicitar Acceso Nuevamente',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            // Llama al método de logout de tu AuthService
                            await _logout(context);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  // Botón para cerrar sesión
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar Sesión'),
                    onPressed: () async {
                      // Llama al método de logout de tu AuthService
                      await _logout(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    showDialog(
      context: context,
      barrierDismissible: false, // Impide que el usuario lo cierre
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color:
                AppTheme.primaryColor, // Asegúrate de tener AppTheme importado
            strokeWidth: 10,
          ),
        );
      },
    );
    await authService.logout();
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/loading', (route) => false);
  }
}

// Widget auxiliar para el fondo, igual al de tus otras pantallas
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
