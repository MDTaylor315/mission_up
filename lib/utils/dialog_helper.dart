import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';

class DialogHelper {
  // Muestra un diálogo de carga que NO roba el foco.
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ✅ La Clave: Hacemos que el diálogo no pueda recibir foco.
        return FocusScope(
          node: FocusScopeNode(canRequestFocus: false),
          child: const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 10,
              ),
            ),
          ),
        );
      },
    );
  }

  // Muestra un diálogo de error que TAMPOCO roba el foco.
  static void showErrorDialog(BuildContext context, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOut.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
          child: Opacity(
            opacity: a1.value,
            // ✅ La Clave: El mismo truco para el diálogo de error.
            child: FocusScope(
              node: FocusScopeNode(canRequestFocus: false),
              child: AlertDialog(
                backgroundColor: const Color(0xFF2C2C2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Ocurrió un Error',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: Text(
                  message,
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    child: const Text('Entendido',
                        style: TextStyle(color: Colors.amber)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
