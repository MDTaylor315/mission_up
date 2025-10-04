import 'package:intl/intl.dart';
import 'package:mission_up/providers/auth_provider.dart';

import 'package:mission_up/repositories/api_service.dart';
import 'package:ntp/ntp.dart';

class AssignmentsRepository {
  static Future<ApiResponse> assignActivities({
    required AuthService authService,
    required String token,
    required List<String> studentIds,
    required List<String> activityIds,
  }) async {
    // ✅ 1. OBTENEMOS LA FECHA ACTUAL DEL DISPOSITIVO
    final DateTime now = await NTP.now();

    // ✅ 2. LA FORMATEAMOS AL FORMATO 'YYYY-MM-DD' QUE ESPERA EL BACKEND
    final String todayString = DateFormat('yyyy-MM-dd').format(now);

    // ✅ 3. CONSTRUIMOS EL 'BODY' DEL JSON CON TODOS LOS DATOS
    final Map<String, dynamic> body = {
      'studentIds': studentIds,
      'activityIds': activityIds,
      'date': todayString, // <-- Aquí enviamos la fecha del cliente
    };

    // ✅ 4. REALIZAMOS LA PETICIÓN POST
    return ApiService.authenticatedRequest(
      endpoint: 'asignaciones/crear',
      method: 'POST',
      authService: authService,
      body: body,
    );
  }
}
