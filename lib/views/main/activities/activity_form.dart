import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/activity_form_controller.dart';
import 'package:mission_up/models/actividad.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:provider/provider.dart';

class ActivityFormScreen extends StatefulWidget {
  /// Si quieres mostrar solo "Editar Actividad", puedes pasar true y
  /// cambiar el título abajo. Por ahora el mock muestra ambos.
  final bool isEdit;
  final Actividad? actividad; // ✅ AÑADE ESTO

  const ActivityFormScreen({super.key, this.isEdit = false, this.actividad});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _controller = ActivityFormController();

  // Junto a tus otras variables de estado y controladores:
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  int? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    // ✅ Si estamos en modo edición, rellenamos los campos
    if (widget.isEdit && widget.actividad != null) {
      final act = widget.actividad!;
      _titleCtrl.text = act.titulo;
      _detailCtrl.text = act.detalle ?? '';
      _pointsCtrl.text = act.puntaje.toString();
      _selectedTypeId = act.idTipoActividad;
    }
  }

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

// En _ActivityFormScreenState

  // En _ActivityFormScreenState

  Future<void> _save() async {
    // 1. Validar el formulario (se mantiene igual)
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // 2. Variable para guardar el resultado de la operación
    bool success;

    // 3. Decidir si ACTUALIZAR o CREAR usando widget.isEdit
    if (widget.isEdit) {
      // --- Lógica de Actualización ---
      success = await _controller.updateActivity(
        context: context,
        activityId:
            widget.actividad!.id.toInt(), // El ID de la actividad a editar
        titulo: _titleCtrl.text,
        detalle: _detailCtrl.text.isNotEmpty ? _detailCtrl.text : null,
        puntaje: int.parse(_pointsCtrl.text),
        idTipoActividad: _selectedTypeId!,
      );
    } else {
      // --- Lógica de Creación (la que ya tenías) ---
      success = await _controller.saveActivity(
        context: context,
        titulo: _titleCtrl.text,
        detalle: _detailCtrl.text.isNotEmpty ? _detailCtrl.text : null,
        puntaje: int.parse(_pointsCtrl.text),
        idTipoActividad: _selectedTypeId!,
      );
    }

    // 4. Manejar el resultado (se mantiene igual, pero con mensaje dinámico)
    if (mounted && success) {
      final message = widget.isEdit
          ? 'Cambios guardados con éxito'
          : 'Actividad creada con éxito';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final actividadesProvider = context.watch<ActividadesProvider>();
    final screenTitle = widget.isEdit ? 'Editar Actividad' : 'Crear Actividad';
    final buttonText = widget.isEdit ? 'Guardar Cambios' : 'Crear Actividad';
    final tipoSeleccionado = _selectedTypeId == null
        ? null
        : actividadesProvider.tipos.firstWhere((t) => t.id == _selectedTypeId);

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
                        screenTitle,
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
                            DropdownButtonFormField<int>(
                              value: _selectedTypeId,
                              isExpanded: true,
                              hint: Text(
                                'Tipo de Actividad', // Corregido: era "Actividada"
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              items: actividadesProvider.tipos.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo.id,
                                  child: Text(tipo.descripcion),
                                );
                              }).toList(),
                              selectedItemBuilder: (BuildContext context) {
                                // Usamos la misma lista de tipos del provider
                                return actividadesProvider.tipos
                                    .map<Widget>((tipo) {
                                  // Para cada tipo en la lista, creamos un widget de Texto
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tipo.descripcion, // Usamos la descripción del tipo actual
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList(); // Convertimos el resultado en una lista de Widgets
                              },
                              onChanged: (v) =>
                                  setState(() => _selectedTypeId = v),
                              validator: (v) =>
                                  v == null ? 'Selecciona un tipo' : null,
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
                            ),

                            const SizedBox(height: 14),

                            // Panel de descripción según el tipo
                            if (tipoSeleccionado !=
                                null) // Usamos el objeto que encontramos
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                // Mostramos el detalle del objeto TipoActividad
                                child: Text(
                                  tipoSeleccionado.detalle ??
                                      'Descripción no disponible.',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
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
                          child: Text(buttonText),
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
