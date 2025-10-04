import 'package:flutter/material.dart';
import 'package:mission_up/models/alumno.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:provider/provider.dart';

class HomeController {
  // El método ahora recibe el objeto 'Alumno' completo,
  // porque el provider lo necesita para la lógica de reversión.
  Future<void> acceptAlumno(BuildContext context, Alumno solicitud) async {
    // 1. Busca el AlumnoProvider
    final alumnoProvider = Provider.of<AlumnoProvider>(context, listen: false);

    // 2. Simplemente delega la acción al provider
    // Ya no hay RequestHandler ni recarga manual. El provider se encarga de todo.
    await alumnoProvider.aceptarSolicitud(solicitud);
  }

  // Hacemos lo mismo para rechazar
  Future<void> rejectAlumno(BuildContext context, Alumno solicitud) async {
    // 1. Busca el AlumnoProvider
    final alumnoProvider = Provider.of<AlumnoProvider>(context, listen: false);

    // 2. Delega la acción al provider
    await alumnoProvider.rechazarSolicitud(solicitud);
  }
}
