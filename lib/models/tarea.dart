// lib/models/tarea.dart

class Tarea {
  final String?
      idAsignacionDetalle; // Puede ser nulo si la tarea no se ha generado para hoy
  final String idActividad;
  final String titulo;
  final int puntaje;
  final bool realizado;

  Tarea({
    this.idAsignacionDetalle,
    required this.idActividad,
    required this.titulo,
    required this.puntaje,
    required this.realizado,
  });

  // El método 'copyWith' es VITAL para la actualización optimista
  // que implementamos en el provider.
  Tarea copyWith({
    String? idAsignacionDetalle,
    String? idActividad,
    String? titulo,
    int? puntaje,
    bool? realizado,
  }) {
    return Tarea(
      idAsignacionDetalle: idAsignacionDetalle ?? this.idAsignacionDetalle,
      idActividad: idActividad ?? this.idActividad,
      titulo: titulo ?? this.titulo,
      puntaje: puntaje ?? this.puntaje,
      realizado: realizado ?? this.realizado,
    );
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      idAsignacionDetalle: json['id_asignacion_detalle'],
      idActividad: json['id_actividad'],
      titulo: json['titulo'],
      puntaje: json['puntaje'],
      realizado: json['realizado'],
    );
  }
}
