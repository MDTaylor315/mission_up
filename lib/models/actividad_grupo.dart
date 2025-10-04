import 'package:mission_up/models/actividad.dart';

class ActividadGrupo {
  final int tipoId;
  final String tipoDescripcion;
  final String? tipoDetalle;
  final List<Actividad> actividades;

  ActividadGrupo({
    required this.tipoId,
    required this.tipoDescripcion,
    this.tipoDetalle,
    required this.actividades,
  });

  factory ActividadGrupo.fromJson(Map<String, dynamic> json) {
    // 1. Toma la lista de 'actividades' del JSON
    var listaDeActividadesJson = json['actividades'] as List;

    // 2. Convierte cada elemento de esa lista en un objeto Actividad
    //    usando el factory 'Actividad.fromJson' que ya tienes.
    List<Actividad> listaDeActividades = listaDeActividadesJson
        .map((actividadJson) => Actividad.fromJson(actividadJson))
        .toList();

    // 3. Crea y devuelve el objeto ActividadGrupo
    return ActividadGrupo(
      tipoId: json['tipo_actividad_id'],
      tipoDescripcion: json['tipo_actividad'],
      tipoDetalle: json['tipo_detalle'],
      actividades: listaDeActividades,
    );
  }
}
