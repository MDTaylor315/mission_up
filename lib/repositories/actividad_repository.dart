import 'package:mission_up/models/actividad.dart';
import 'package:mission_up/models/actividad_grupo.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/api_service.dart';

class ActividadRepository {
  static String _endpoint(String path) => 'actividades/$path';

  static Future<ApiResponse<Actividad>> createActividad({
    required AuthService authService,
    required Map<String, dynamic> data,
  }) async {
    return ApiService.authenticatedRequest<Actividad>(
      endpoint: _endpoint(''),
      method: 'POST',
      authService: authService,
      body: data,
      fromJson: (json) => Actividad.fromJson(json),
    );
  }

  static Future<ApiResponse<List<ActividadGrupo>>> getActividadesAgrupadas({
    required AuthService authService,
  }) async {
    return ApiService.authenticatedRequest<List<ActividadGrupo>>(
      endpoint: _endpoint(''),
      method: 'GET',
      authService: authService,
      fromJson: (jsonList) {
        return (jsonList as List)
            .map((item) => ActividadGrupo.fromJson(item))
            .toList();
      },
    );
  }

  static Future<ApiResponse<Actividad>> updateActividad({
    required AuthService authService,
    required int activityId,
    required Map<String, dynamic> data,
  }) async {
    return ApiService.authenticatedRequest<Actividad>(
      endpoint: _endpoint('$activityId'), // Llama a /actividades/{id}
      method: 'PATCH', // Usa el método PATCH
      authService: authService, body: data,
      fromJson: (json) => Actividad.fromJson(json),
    );
  }

  static Future<ApiResponse<void>> deleteActividad({
    required AuthService authService,
    required String token,
    required int activityId,
  }) async {
    // Usamos <void> porque no esperamos datos en la respuesta
    return ApiService.authenticatedRequest<void>(
      endpoint: _endpoint('$activityId'), // Llama a /actividades/{id}
      method: 'DELETE',
      authService: authService, fromJson: (_) => {}, // No hay JSON que parsear
    );
  }
}
