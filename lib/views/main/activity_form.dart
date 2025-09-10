import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mission_up/app_theme.dart';

class ActivityFormScreen extends StatefulWidget {
  /// Si quieres mostrar solo "Editar Actividad", puedes pasar true y
  /// cambiar el título abajo. Por ahora el mock muestra ambos.
  final bool isEdit;
  const ActivityFormScreen({super.key, this.isEdit = false});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  String? _type; // 'tarea' | 'premio' | 'castigo'

  final Map<String, String> _typeDescriptions = const {
    'tarea':
        'Descripción Tipo de Actividad\nTarea: Se otorgarán puntos cuando se cumpla.',
    'premio':
        'Descripción Tipo de Actividad\nPremio: Se canjean puntos para obtener recompensas.',
    'castigo':
        'Descripción Tipo de Actividad\nCastigo: Se restarán puntos, etc...',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: AppTheme.blackLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0)),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad guardada')),
      );
      // TODO: persistir (API/DB)
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: IconButton(
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: AppTheme.coinsColor),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ),

                      // Título
                      Text(
                        'Crear Actividad / Editar Actividad',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 16),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Tipo Actividad (Dropdown) - SOLUCIÓN AQUÍ
                            DropdownButtonFormField<String>(
                              value: _type,
                              isExpanded: true,
                              hint: Text(
                                'Tipo de Actividad', // Corregido: era "Actividada"
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'tarea', child: Text('Tarea')),
                                DropdownMenuItem(
                                    value: 'premio', child: Text('Premio')),
                                DropdownMenuItem(
                                    value: 'castigo', child: Text('Castigo')),
                              ],
                              selectedItemBuilder: (_) => const [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Tarea',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700))),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Premio',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700))),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Castigo',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700))),
                              ],
                              onChanged: (v) => setState(() => _type = v),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              dropdownColor: AppTheme.blackLight,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.blackLight,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                ),
                              ),
                              validator: (v) =>
                                  v == null ? 'Selecciona el tipo' : null,
                            ),

                            const SizedBox(height: 14),

                            // Panel de descripción según el tipo
                            if (_type != null)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Text(
                                  _typeDescriptions[_type] ??
                                      'Descripción Tipo de Actividad',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              // Para reservar espacio similar al mock
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                child: Text(
                                  'Descripción Tipo de Actividad\nCastigo : Se restarán puntos etc......',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 14),

                            // Título de Actividad
                            TextFormField(
                              controller: _titleCtrl,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              decoration: _decor('Título de Actividad'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Ingresa un título'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Puntaje
                            TextFormField(
                              controller: _pointsCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              decoration: _decor(
                                'Puntaje',
                                suffix: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/icons/coins.svg',
                                    width: 30,
                                    colorFilter: ColorFilter.mode(
                                        AppTheme.coinsColor, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingresa un puntaje'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Botón guardar (pegado abajo como en el mock)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor:
                                const Color.fromARGB(255, 199, 223, 206),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _save,
                          child: const Text('Guardar Actividad'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
