class Actividad {
  final BigInt id;
  final int idTipoActividad;
  final String titulo;
  final String? detalle;
  final int puntaje;

  Actividad({
    required this.id,
    required this.idTipoActividad,
    required this.titulo,
    this.detalle,
    required this.puntaje,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: BigInt.parse(json['id_actividad'].toString()),
      idTipoActividad: json['id_tipo_actividad'],
      titulo: json['titulo'],
      detalle: json['detalle'],
      puntaje: json['puntaje'],
    );
  }
}
