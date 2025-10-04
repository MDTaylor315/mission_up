import 'package:mission_up/models/tarea.dart';

class EstadoAlumno {
  static const String pendiente = 'PENDIENTE';
  static const String aceptado = 'ACEPTADO';
}

class Alumno {
  final BigInt id;
  final BigInt idRelacion; // Muy útil para las acciones con solicitudes
  final String nombre;
  final String? avatarUrl;
  final int puntaje;
  final String? estado;

  // Campos adicionales para alumnos aceptados
  final String resumenTareas;
  final int puntosHoy;
  final List<Tarea> tareas;

  Alumno({
    required this.id,
    required this.idRelacion,
    required this.nombre,
    this.avatarUrl,
    required this.puntaje,
    this.estado,
    required this.resumenTareas,
    required this.puntosHoy,
    required this.tareas,
  });

  /// Crea una copia de este Alumno, pero con los valores proporcionados.
  /// Los valores que no se proporcionen se mantendrán igual.
  Alumno copyWith({
    BigInt? id,
    BigInt? idRelacion,
    String? nombre,
    String? avatarUrl,
    int? puntaje,
    String? estado,
    String? resumenTareas,
    int? puntosHoy,
    List<Tarea>? tareas,
  }) {
    return Alumno(
      id: id ?? this.id,
      idRelacion: idRelacion ?? this.idRelacion,
      nombre: nombre ?? this.nombre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      puntaje: puntaje ?? this.puntaje,
      estado: estado ?? this.estado,
      resumenTareas: resumenTareas ?? this.resumenTareas,
      puntosHoy: puntosHoy ?? this.puntosHoy,
      tareas: tareas ?? this.tareas,
    );
  }

  factory Alumno.fromJson(Map<String, dynamic> json) {
    var tareasList = json['tareas'] as List? ?? [];
    List<Tarea> tareas = tareasList.map((i) => Tarea.fromJson(i)).toList();

    return Alumno(
      id: BigInt.parse(json['id_usuario'].toString()),
      idRelacion:
          BigInt.tryParse(json['id_relacion']?.toString() ?? '') ?? BigInt.zero,
      nombre: json['nombre'],
      avatarUrl: json["avatar_url"],
      puntaje: json['puntaje_actual'],
      estado: json['estado'],
      resumenTareas: json['resumen_tareas'],
      puntosHoy: json['puntos_hoy'],
      tareas: tareas,
    );
  }
}
