import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/alumno_controller.dart';
import 'package:mission_up/controllers/assignments_controller.dart';
import 'package:mission_up/models/alumno.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/routes/fade_transition.dart';
import 'package:mission_up/views/main/activities/activities_picker_screen.dart';
import 'package:provider/provider.dart';

class StudentsSelectScreen extends StatefulWidget {
  const StudentsSelectScreen({super.key});

  @override
  State<StudentsSelectScreen> createState() => _StudentsSelectScreenState();
}

class _StudentsSelectScreenState extends State<StudentsSelectScreen> {
  final _controller = AssignmentsController();
  final Set<BigInt> _selected = {};
  String _q = '';

  List<Alumno> _getFilteredAlumnos(List<Alumno> acceptedAlumnos) {
    if (_q.trim().isEmpty) return acceptedAlumnos;
    final q = _q.toLowerCase();
    return acceptedAlumnos
        .where((s) => s.nombre.toLowerCase().contains(q))
        .toList();
  }

  bool _areAllFilteredSelected(List<Alumno> filtered) {
    final filteredIds = filtered.map((e) => e.id).toSet();
    return filteredIds.isNotEmpty && filteredIds.difference(_selected).isEmpty;
  }

  void _toggleAll(List<Alumno> filtered) {
    setState(() {
      final allSelected = _areAllFilteredSelected(filtered);
      if (allSelected) {
        _selected.removeAll(filtered.map((e) => e.id));
      } else {
        _selected.addAll(filtered.map((e) => e.id));
      }
    });
  }

  void _toggleOne(BigInt id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _goPickActivities() async {
    // Suponemos que ActivitiesPickerScreen devuelve una lista de IDs de actividad como List<String>

    final pickedActivities = await Navigator.of(context).pushNamed(
      "/activities",
    );

    if (pickedActivities == null || (pickedActivities as List).isEmpty) {
      // El usuario no seleccionó ninguna actividad o canceló
      _selected.clear(); // Limpiamos la selección de alumnos
      return;
    }
    await _controller.assignActivities(
      context: context,
      studentIds: _selected,
      activityIds: pickedActivities as List<String>,
    );
    _selected.clear(); // Limpiamos la selección de alumnos
    setState(() {}); // Forzamos la actualización de la UI
  }

  @override
  void initState() {
    super.initState();
    // Usamos 'addPostFrameCallback' para asegurar que el contexto esté disponible
    // cuando llamemos al provider. Es la forma más segura de hacerlo en initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtenemos las instancias de nuestros servicios/providers.
      // Usamos 'read' en lugar de 'watch' porque solo estamos llamando a una acción,
      // no necesitamos escuchar cambios aquí.
      final alumnoProvider = context.read<AlumnoProvider>();

      // ¡Aquí está la llamada que faltaba!
      // Le pedimos al provider que cargue los alumnos activos.
      // No pasamos fecha porque esta pantalla necesita a TODOS los alumnos aceptados.
      alumnoProvider.fetchAlumnosActivos();
      alumnoProvider.fetchSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlumnoProvider>();
    final filtered = _getFilteredAlumnos(provider.alumnosActivos);
    final allSelected = _areAllFilteredSelected(filtered);
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
                  Icons.boy_rounded,
                  color: AppTheme.primaryColor,
                ),
                Text('Paso 1: Seleccionar Alumnos',
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
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              // Barra de Búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar alumno...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(.5)),
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

              // "Seleccionar todo"
              _SelectAllTile(
                count: _selected.length,
                allSelected: allSelected,
                onTap: () => _toggleAll(filtered),
              ),

              // Lista de Alumnos
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(
                            child: Text(provider.error!,
                                style:
                                    const TextStyle(color: Colors.redAccent)))
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                                16, 8, 16, 100 + bottomInset),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final alumno = filtered[i];
                              final isSelected = _selected.contains(alumno.id);
                              return _StudentTile(
                                alumno: alumno,
                                isSelected: isSelected,
                                onTap: () => _toggleOne(alumno.id),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        // Botón de acción inferior
        if (_selected.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: FilledButton(
              onPressed: _goPickActivities,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Siguiente (${_selected.length})',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// --- Widgets Auxiliares ---

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

class _SelectAllTile extends StatelessWidget {
  final int count;
  final bool allSelected;
  final VoidCallback onTap;

  const _SelectAllTile({
    required this.count,
    required this.allSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.blackLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                onChanged: (_) => onTap(),
                activeColor: AppTheme.primaryColor,
                checkColor: AppTheme.black,
              ),
              const Text('Seleccionar todos',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '$count seleccionados',
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Alumno alumno;
  final bool isSelected;
  final VoidCallback onTap;

  const _StudentTile({
    required this.alumno,
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
        leading: CircleAvatar(
          backgroundColor: isSelected ? AppTheme.primaryColor : AppTheme.grey,
          backgroundImage:
              alumno.avatarUrl != null ? NetworkImage(alumno.avatarUrl!) : null,
          child: alumno.avatarUrl == null
              ? Text(
                  alumno.nombre.isNotEmpty
                      ? alumno.nombre[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.black : Colors.white,
                  ),
                )
              : null,
        ),
        title: Text(
          alumno.nombre,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
