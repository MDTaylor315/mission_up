import 'package:flutter/material.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/actividad_repository.dart';
import 'package:mission_up/repositories/request_handler.dart';
import 'package:provider/provider.dart';

class ActivitiesController {
  Future<bool> deleteActivity({
    required BuildContext context,
    required int activityId,
  }) async {
    final authService = context.read<AuthService>();
    final token = authService.accessToken;
    if (token == null) return false;

    final response = await RequestHandler.handle(
      context,
      () => ActividadRepository.deleteActividad(
        authService: authService,
        token: token,
        activityId: activityId,
      ),
    );

    if (response != null && response.isSuccess) {
      // Si el borrado fue exitoso, refrescamos la lista
      await context.read<ActividadesProvider>().fetchActividades();
      //
      return true;
    }
    return false;
  }

  // Se llama cuando el texto del buscador cambia
  void onSearchChanged(String query, BuildContext context) {
    // Usamos 'read' porque solo estamos llamando a un método, no necesitamos
    // que el controller se reconstruya.
    context.read<ActividadesProvider>().updateSearchQuery(query);
  }

  // Se llama cuando el usuario selecciona un tipo de actividad (chip)
  void onSelectTipo(int tipoId, BuildContext context) {
    context.read<ActividadesProvider>().selectTipo(tipoId);
  }
}
