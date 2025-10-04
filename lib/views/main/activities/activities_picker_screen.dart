import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/models/actividad.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/widgets/widgets.dart'; // Para el helper monedas()
import 'package:provider/provider.dart';

// --- Widget Envoltorio con Provider ---
// Este widget se encarga de crear el ActividadesProvider.
// Llama a esta pantalla usando ActivitiesPickerProviderScreen().
class ActivitiesPickerScreen extends StatefulWidget {
  const ActivitiesPickerScreen({super.key});

  @override
  State<ActivitiesPickerScreen> createState() => _ActivitiesPickerScreenState();
}

class _ActivitiesPickerScreenState extends State<ActivitiesPickerScreen> {
  final Set<BigInt> _selected = {};
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(BigInt activityId) {
    setState(() {
      if (_selected.contains(activityId)) {
        _selected.remove(activityId);
      } else {
        _selected.add(activityId);
      }
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selected.map((id) => id.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.read aquí para la acción de búsqueda, es más eficiente.
    final providerActions = context.read<ActividadesProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        const _GradientBg(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(
                  width: 5,
                ),
                Text('Paso 2: Elegir actividades',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.white)),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) => providerActions.updateSearchQuery(text),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Buscar Tareas, Premios...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppTheme.blackLight,
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Lista de Actividades
              Expanded(
                child: Consumer<ActividadesProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.error != null) {
                      return Center(
                        child: Text('Error: ${provider.error}',
                            style: const TextStyle(color: Colors.redAccent)),
                      );
                    }

                    return ListView(
                      padding:
                          EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomInset),
                      children: provider.gruposMostrados.map((grupo) {
                        if (grupo.actividades.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(grupo.tipoDescripcion),
                            const SizedBox(height: 12),
                            ...grupo.actividades.map((actividad) {
                              final isSelected =
                                  _selected.contains(actividad.id);
                              return _SelectableActivityTile(
                                actividad: actividad,
                                isSelected: isSelected,
                                onTap: () => _toggleSelection(actividad.id),
                              );
                            }).toList(),
                            const SizedBox(height: 22),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Botón de Confirmación
        if (_selected.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _confirmSelection,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: const Color.fromARGB(255, 20, 31, 23),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                child: Text(
                  'Confirmar (${_selected.length})',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
// --- Widgets Auxiliares (sin cambios de lógica, solo revisión de sintaxis) ---

class _GradientBg extends StatelessWidget {
  const _GradientBg();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1C), Color(0xFF040404)],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // ✅ CORRECCIÓN: Usando .copyWith para asegurar que el estilo base del tema se aplique
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
    );
  }
}

class _SelectableActivityTile extends StatelessWidget {
  final Actividad actividad;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableActivityTile({
    required this.actividad,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected
          ? AppTheme.primaryColor.withOpacity(0.25)
          : AppTheme.blackLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          actividad.titulo,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: monedas(actividad.puntaje),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => onTap(),
          activeColor: AppTheme.primaryColor,
          checkColor: AppTheme.black,
        ),
      ),
    );
  }
}
