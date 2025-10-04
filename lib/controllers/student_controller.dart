import 'package:flutter/material.dart';
import 'package:mission_up/repositories/auth_repository.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/request_handler.dart';
import 'package:provider/provider.dart';

class StudentController {
  Future<bool> loginOrRegisterStudent(
    BuildContext context, {
    required String username,
    required String familyCode,
  }) async {
    final response = await RequestHandler.handle(
      context,
      () {
        // Llama al repositorio para hacer la petición
        return AuthRepository.loginOrRegisterStudent(
          username: username.trim(),
          codigoInvitacion: familyCode,
        );
      },
    );

    if (response != null && response.isSuccess && response.data != null) {
      // Llama al AuthService para que guarde la sesión y actualice el estado global.
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.handleLoginSuccess(response.data!);
      if (!authService.currentUser!.isAdmin &&
          !authService.currentUser!.isAccepted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/pending",
          (route) => false,
        );
        return true;
      }
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
