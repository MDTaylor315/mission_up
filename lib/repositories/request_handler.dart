import 'package:flutter/material.dart';
import 'package:mission_up/repositories/api_service.dart'; // Importa tu ApiResponse
import 'package:mission_up/utils/dialog_helper.dart'; // Importa el helper de diálogos

class RequestHandler {
  // Este método envuelve cualquier llamada a la API
  static Future<ApiResponse<T>?> handle<T>(
    BuildContext context,
    Future<ApiResponse<T>> Function() apiCall,
  ) async {
    FocusScope.of(context).unfocus();

    // Guardamos una referencia al Navigator para usarla de forma segura
    final navigator = Navigator.of(context, rootNavigator: true);

    // 1. Muestra el diálogo de carga
    DialogHelper.showLoadingDialog(context);

    ApiResponse<T>? response;

    try {
      // 2. Ejecuta la llamada a la API y guarda la respuesta
      response = await apiCall();
    } catch (e) {
      // Si hay una excepción inesperada (ej. sin internet), crea una respuesta de error
      response =
          ApiResponse.error('Ocurrió un error de conexión: ${e.toString()}');
    } finally {
      // 3. ✅ LA MAGIA: ESTE BLOQUE SIEMPRE SE EJECUTA
      // Cierra el diálogo de carga, sin importar si la API tuvo éxito o no.
      if (navigator.canPop()) {
        navigator.pop();
      }
    }

    if (response != null && !response.isSuccess) {
      DialogHelper.showErrorDialog(
          context, response.error ?? 'Error desconocido');
      return null; // Devuelve null para indicar que la operación falló
    }

    // 5. Si fue exitosa, devuelve la respuesta
    return response;
  }

  static Future<bool> handleAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    // ✅ 1. Misma lógica de unfocus y navigator
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context, rootNavigator: true);

    // ✅ 2. Usando tu mismo DialogHelper para la carga
    DialogHelper.showLoadingDialog(context);

    Object? error; // Variable para guardar un posible error

    try {
      // 3. Ejecuta el bloque de acción completo
      await action();
    } catch (e) {
      // Si algo dentro de 'action' lanza una excepción, la guardamos
      error = e;
    } finally {
      // ✅ 4. Misma lógica 'finally' para asegurar que el loading siempre se cierre
      if (navigator.canPop()) {
        navigator.pop();
      }
    }

    // 5. Si guardamos un error, lo mostramos y devolvemos 'false'
    if (error != null) {
      DialogHelper.showErrorDialog(
          context, error.toString().replaceFirst('Exception: ', ''));
      return false;
    }

    // 6. Si no hubo errores, la operación fue un éxito, devolvemos 'true'
    return true;
  }
}
