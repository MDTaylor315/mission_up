import 'package:flutter/material.dart';
import 'package:mission_up/repositories/auth_repository.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/request_handler.dart';
import 'package:provider/provider.dart';

class LoginController {
  Future<bool> login(BuildContext context,
      {required String contacto, required String password}) async {
    final response = await RequestHandler.handle(
      context,
      () {
        // Llama al repositorio para hacer la petición
        return AuthRepository.login(
            contact: contacto, // Usa las variables reales
            password: password);
      },
    );

    // ✅ Si la respuesta no es nula, el login fue exitoso.
    if (response != null && response.isSuccess && response.data != null) {
      // Llama al AuthService para que guarde la sesión y actualice el estado global.
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.handleLoginSuccess(response.data!);
      Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false,
          arguments: {
            'tab': 0,
          });
      return true; // Devuelve true para indicar éxito
    }

    // Si la respuesta es nula o falló, devuelve false.
    return false;
  }
}
