// lib/controllers/assignments_controller.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/asignacion_repository.dart';
import 'package:mission_up/repositories/request_handler.dart'; // Tu RequestHandler
import 'package:provider/provider.dart';

class AssignmentsController {
  Future<void> assignActivities({
    required BuildContext context,
    required Set<BigInt> studentIds,
    required List<String> activityIds,
  }) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final studentIdsAsString = studentIds.map((id) => id.toString()).toList();

    // ✅ 1. Llamamos a tu 'handleAction' y guardamos el resultado booleano
    final bool success = await RequestHandler.handleAction(
      context,
      () async {
        // La acción a ejecutar sigue siendo la misma: llamar al repositorio
        final response = await AssignmentsRepository.assignActivities(
          authService: authService,
          token: authService.accessToken!,
          studentIds: studentIdsAsString,
          activityIds: activityIds,
        );

        // Si la API devuelve un error, lo lanzamos para que handleAction lo capture
        if (!response.isSuccess) {
          throw Exception(
              response.error ?? 'Error desconocido al asignar actividades.');
        }
      },
    );

    // ✅ 2. Si la acción fue exitosa (handleAction devolvió 'true')
    //    Usamos 'context.mounted' como buena práctica para evitar errores.
    if (success && context.mounted) {
      // a) Mostramos un mensaje de éxito manualmente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actividades asignadas correctamente.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      // b) Ejecutamos la lógica para refrescar los datos
      final alumnosProvider =
          Provider.of<AlumnoProvider>(context, listen: false);
      final String todayString =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Le decimos al provider que refresque la lista de alumnos activos para hoy
      alumnosProvider.fetchAlumnosActivos(fecha: todayString);
    }
  }
}
