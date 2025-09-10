// lib/views/invite_register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mission_up/app_theme.dart';

class InviteRegisterScreen extends StatefulWidget {
  const InviteRegisterScreen({super.key});

  @override
  State<InviteRegisterScreen> createState() => _InviteRegisterScreenState();
}

class _InviteRegisterScreenState extends State<InviteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _codeFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _nameFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(.95),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: AppTheme.blackLight, // gris oscuro de tus tarjetas
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.0)),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      // Aquí haces tu lógica real (API, provider, etc.)
      Navigator.of(context).pushNamed("/loading");
      // Simular un retraso de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        // Aquí podrías navegar a la pantalla principal o donde sea necesario
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/main",
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // deja ver el gradiente global
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flecha atrás
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    // color: Colors.red,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFFFFA754)), // naranja del mock
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),

                const SizedBox(height: 8),

                // Título
                Text(
                  'Registro con código de\ninvitación',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 12),

                // Descripción
                Text(
                  'Solicita al tutor el código de invitación\npara unirte a la familia',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 24),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _decor('Nombres y Apellidos'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa tu nombre'
                            : null,
                        onFieldSubmitted: (_) => _codeFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeCtrl,
                        focusNode: _codeFocus,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-]')),
                          UpperCaseTextFormatter(),
                        ],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        decoration: _decor('Código de Invitación'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa el código'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botón inferior
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: const Color.fromARGB(255, 199, 223, 206),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Unirme a la familia',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Transforma a MAYÚSCULAS manteniendo la posición del cursor.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
