import 'package:flutter/material.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/actividad_repository.dart';
import 'package:mission_up/repositories/request_handler.dart';
import 'package:provider/provider.dart';

class ActivityFormController {
  Future<bool> saveActivity({
    required BuildContext context,
    required String titulo,
    String? detalle, // Añadido el detalle
    required int puntaje,
    required int idTipoActividad,
  }) async {
    final authService = context.read<AuthService>();
    final token = authService.accessToken;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
      return false;
    }

    final data = {
      'titulo': titulo,
      'detalle': detalle,
      'puntaje': puntaje,
      'id_tipo_actividad': idTipoActividad,
    };

    final response = await RequestHandler.handle(
      context,
      () => ActividadRepository.createActividad(
          authService: authService, data: data),
    );

    // Si el handler devuelve una respuesta exitosa, procede
    if (response != null && response.isSuccess) {
      await context.read<ActividadesProvider>().fetchActividades();
      return true;
    }
    return false;
  }

  Future<bool> updateActivity({
    required BuildContext context,
    required int activityId,
    required String titulo,
    String? detalle,
    required int puntaje,
    required int idTipoActividad,
  }) async {
    final authService = context.read<AuthService>();
    final token = authService.accessToken;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
      return false;
    }
    final data = {
      'titulo': titulo,
      'detalle': detalle,
      'puntaje': puntaje,
      'id_tipo_actividad': idTipoActividad,
    };

    final response = await RequestHandler.handle(
      context,
      () => ActividadRepository.updateActividad(
        authService: authService,
        activityId: activityId,
        data: data,
      ),
    );

    if (response != null && response.isSuccess) {
      await context.read<ActividadesProvider>().fetchActividades();
      return true;
    }
    return false;
  }
}
