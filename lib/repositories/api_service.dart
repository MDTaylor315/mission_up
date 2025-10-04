// api_service.dart - Versión mejorada
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mission_up/providers/auth_provider.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse._({this.data, this.error, this.statusCode});

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  // Hacemos que 'data' sea opcional (T?) para manejar respuestas sin contenido (ej. 204)
  factory ApiResponse.success(T? data, {int? statusCode}) {
    return ApiResponse._(data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String errorMessage, {int? statusCode}) {
    return ApiResponse._(error: errorMessage, statusCode: statusCode);
  }
}

class ApiService {
  //static const String baseUrl = 'http://172.21.25.141:3000';
  static const String baseUrl = 'http://192.168.18.8:3000';

  static const int timeoutSeconds = 30;

  // Headers comunes
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Método request (ya lo tienes bien)
  static Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? extraHeaders,
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParameters,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final headers = {...getHeaders(token), ...?extraHeaders};

      // ✅ Usar los métodos específicos de http
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: timeoutSeconds));
          break;
        case 'POST':
          print("login 1 $json.encode(body) $uri");
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: timeoutSeconds));
          print("login 2");
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: timeoutSeconds));
          break;
        case 'PATCH':
          response = await http
              .patch(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: timeoutSeconds));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: timeoutSeconds));
          break;
        default:
          return ApiResponse.error(
            'Método HTTP no soportado: $method',
            statusCode: 405, // ✅ 405 Method Not Allowed
          );
      }
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Es un éxito sin contenido, como el logout
          return ApiResponse.success(null as T,
              statusCode: response.statusCode);
        } else {
          // Es un error pero el cuerpo vino vacío
          return ApiResponse.error('Error desconocido (cuerpo vacío)',
              statusCode: response.statusCode);
        }
      }
      final responseBody = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("request login");
        // Success
        if (fromJson != null) {
          final data = fromJson(responseBody);
          print("data $data");
          return ApiResponse.success(data, statusCode: response.statusCode);
        } else {
          return ApiResponse.success(responseBody as T,
              statusCode: response.statusCode);
        }
      } else {
        // Error del servidor
        print("error login $responseBody ");
        final errorMessage =
            _parseErrorMessage(responseBody, response.statusCode);
        return ApiResponse.error(errorMessage, statusCode: response.statusCode);
      }
    } on TimeoutException {
      print("Tiempo de espera agotado. Verifica tu conexión a internet.");
      return ApiResponse.error(
        'Tiempo de espera agotado. Verifica tu conexión.',
        statusCode: 408,
      );
    } on http.ClientException catch (e) {
      print("'Error de conexión: ${e.message}");
      return ApiResponse.error(
        'Error de conexión. Revisa tu conexión a internet.',
        statusCode: 503,
      );
    } on FormatException catch (e) {
      print(" Error en el formato de la respuesta del servidor. ${e.message}");
      return ApiResponse.error(
        'Error en el formato de la respuesta del servidor.',
        statusCode: 400,
      );
    } catch (e, stacktrace) {
      print("Error inesperado: $e   -   $stacktrace");
      return ApiResponse.error(
        'Error inesperado en la aplicación.',
        statusCode: 500,
      );
    }
  }

  // Método helper para endpoints con autenticación
  static Future<ApiResponse<T>> authenticatedRequest<T>({
    required AuthService
        authService, // <-- 1. Ahora recibe la instancia de AuthService
    required String endpoint,
    required String method,
    dynamic body,
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParameters,
  }) async {
    String? token = authService.accessToken;

    if (token == null) {
      // Si por alguna razón no hay token, fallamos rápido.
      return ApiResponse.error("No hay un token de acceso disponible.",
          statusCode: 401);
    }

    // --- PRIMER INTENTO ---
    // Hacemos la llamada a la API con el token actual.
    var response = await request<T>(
      endpoint: endpoint,
      method: method,
      body: body,
      token: token,
      fromJson: fromJson,
      queryParameters: queryParameters,
    );

    // --- INTERCEPTOR: MANEJO DEL 401 ---
    // 2. Si la respuesta es 401 (Unauthorized), el token expiró.
    if (response.statusCode == 401) {
      print("Token expirado. Intentando refrescar...");

      // 3. Llamamos al método que creamos en AuthService para refrescar.
      final newAccessToken = await authService.tryRefreshToken();

      // 4. Si obtuvimos un nuevo token...
      if (newAccessToken != null) {
        print("Refresco exitoso. Reintentando la petición original...");

        // --- SEGUNDO INTENTO (REINTENTO) ---
        // Reintentamos la petición original, pero ahora con el nuevo token.
        response = await request<T>(
          endpoint: endpoint,
          method: method,
          body: body,
          token: newAccessToken, // <-- Usamos el token nuevo
          fromJson: fromJson,
          queryParameters: queryParameters,
        );
      }
    }

    // 5. Devolvemos la respuesta final (sea del primer o segundo intento).
    return response;
  }

  // Parsear mensajes de error específicos del backend
  static String _parseErrorMessage(dynamic responseBody, int statusCode) {
    try {
      if (responseBody is Map<String, dynamic>) {
        // Manejar errores de NestJS/Prisma
        if (responseBody['message'] != null) {
          return responseBody['message'];
        }
        if (responseBody['error'] != null) {
          return responseBody['error'];
        }
      }

      // Mensajes por código de estado
      switch (statusCode) {
        case 400:
          return 'Solicitud incorrecta';
        case 401:
          return 'No autorizado';
        case 403:
          return 'Acceso denegado';
        case 404:
          return 'Recurso no encontrado';
        case 500:
          return 'Error interno del servidor';
        default:
          return 'Error desconocido (Código: $statusCode)';
      }
    } catch (e) {
      return 'Error procesando la respuesta del servidor';
    }
  }
}
