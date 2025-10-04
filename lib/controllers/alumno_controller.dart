import 'package:flutter/material.dart';
// TODO: Importa tu AsignacionRepository cuando lo crees

class AlumnoController {
  Future<void> assignActivities({
    required BuildContext context,
    required Set<BigInt> studentIds,
    required List<String> activityIds,
  }) async {
    final studentIdsAsString = studentIds.map((id) => id.toString()).toList();
    final activitiesIdsAsString =
        activityIds.map((id) => id.toString()).toList();

    // --- LÓGICA SIMULADA MIENTRAS CONSTRUYES EL BACKEND ---
    final response = true; // Simula una respuesta exitosa
    // --- FIN DE LÓGICA SIMULADA ---

    if (response != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Asignadas ${studentIdsAsString.length} actividad(es) a ${activitiesIdsAsString.length} alumno(s).',
          ),
          backgroundColor: Colors.green[700],
        ),
      );
      // Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
