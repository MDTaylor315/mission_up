// auth_repository.dart

import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/api_service.dart';

class AuthRepository {
  static String _endpoint(String service) => 'auth/$service';
  // Login o registro de estudiante
  static Future<ApiResponse<Map<String, dynamic>>> loginOrRegisterStudent({
    required String username,
    required String codigoInvitacion,
  }) async {
    return ApiService.request<Map<String, dynamic>>(
      endpoint: _endpoint('student'),
      method: 'POST',
      body: {
        'username': username,
        'codigo_invitacion': codigoInvitacion,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Login tradicional
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String contact,
    required String password,
  }) async {
    print("login");
    return ApiService.request<Map<String, dynamic>>(
      endpoint: _endpoint('login/tutor'),
      method: 'POST',
      body: {
        'contacto': contact,
        'contrasena': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Registro de usuario
  static Future<ApiResponse<Map<String, dynamic>>> register(
      {required String contacto,
      required String contrasena,
      required String nombre,
      required String proveedor}) async {
    return ApiService.request<Map<String, dynamic>>(
      endpoint: _endpoint("register/tutor"),
      method: 'POST',
      body: {
        'contacto': contacto,
        'contrasena': contrasena,
        'nombre': nombre,
        'proveedor': proveedor
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ✅ El método ahora recibe el token que necesita.
  static Future<ApiResponse<void>> logout(
      {required AuthService authService}) async {
    return ApiService.authenticatedRequest<void>(
      endpoint: _endpoint(
          'logout'), // Usamos el helper para la ruta completa 'auth/logout'
      method: 'POST',
      authService: authService,
    );
  }

  // Verificar token
  static Future<ApiResponse<Map<String, dynamic>>> verifyToken(
      AuthService authService) async {
    return ApiService.authenticatedRequest<Map<String, dynamic>>(
      endpoint: 'auth/verify',
      method: 'GET',
      authService: authService,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> refreshToken(
      {required String refreshToken,
      required String sessionId,
      String? tutorId}) async {
    return ApiService.request<Map<String, dynamic>>(
      endpoint: _endpoint('refresh'),
      method: 'POST',
      body: {
        'refresh_token': refreshToken,
        'session_id': sessionId,
        'tutor_id': tutorId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
