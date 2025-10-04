class TipoActividad {
  final int id;
  final String descripcion;
  final String? detalle;

  TipoActividad({required this.id, required this.descripcion, this.detalle});

  factory TipoActividad.fromJson(Map<String, dynamic> json) {
    // 1. Toma la lista de 'actividades' del JSON

    // 3. Crea y devuelve el objeto ActividadGrupo
    return TipoActividad(
      id: json['id_tipo_actividad'],
      descripcion: json['descripcion'],
      detalle: json['detalle'],
    );
  }
}
