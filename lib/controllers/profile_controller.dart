import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/repositories/auth_repository.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/request_handler.dart';
import 'package:provider/provider.dart';

class ProfileController {
  Future<void> logout(BuildContext context) async {
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

    // 4. (MUY IMPORTANTE) Antes de usar 'context' después de un 'await',
    //    verifica siempre que el widget todavía esté en pantalla.
    // 1. El controller obtiene la instancia de AuthService desde el contexto.
    final authService = Provider.of<AuthService>(context, listen: false);

    // 2. Le delega la tarea de logout al experto (AuthService).
    //    No necesita saber cómo funciona por dentro, solo le da la orden.
    await authService.logout();

    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/loading', (route) => false);
  }
}
