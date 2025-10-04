import 'package:mission_up/models/alumno.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/api_service.dart';

class AlumnoRepository {
  static String _endpoint(String path) => 'alumnos/$path';

  static Future<ApiResponse<List<Alumno>>> getSolicitudes({
    required AuthService authService,
  }) async {
    return ApiService.authenticatedRequest<List<Alumno>>(
      endpoint: _endpoint('solicitudes'),
      method: 'GET',
      authService: authService,
      fromJson: (jsonList) {
        return (jsonList as List).map((item) => Alumno.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse<List<Alumno>>> getAlumnosActivos({
    required AuthService authService,
    String? fecha, // Recibe 'YYYY-MM-DD'
  }) async {
    final Map<String, String> queryParams = {};
    if (fecha != null) {
      queryParams['fecha'] = fecha;
    }

    return ApiService.authenticatedRequest<List<Alumno>>(
      endpoint: _endpoint('activos'),
      method: 'GET',
      authService: authService,
      queryParameters: queryParams,
      fromJson: (jsonList) {
        return (jsonList as List).map((item) => Alumno.fromJson(item)).toList();
      },
    );
  }

  static Future<ApiResponse> acceptAlumno({
    required AuthService authService,
    required BigInt alumnoId,
  }) async {
    return ApiService.authenticatedRequest(
      endpoint: _endpoint('aceptar/$alumnoId'),
      method: 'PATCH',
      authService: authService,
    );
  }

  static Future<ApiResponse> rejectAlumno({
    required AuthService authService,
    required BigInt alumnoId,
  }) async {
    return ApiService.authenticatedRequest(
      endpoint: _endpoint('rechazar/$alumnoId'),
      method: 'PATCH',
      authService: authService,
    );
  }
}
