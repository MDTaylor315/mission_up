// lib/views/main/students_select_screen.dart
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/routes/fade_transition.dart';
import 'package:mission_up/views/main/activities_picker.dart';

class StudentsSelectScreen extends StatefulWidget {
  const StudentsSelectScreen({super.key});

  @override
  State<StudentsSelectScreen> createState() => _StudentsSelectScreenState();
}

class _StudentsSelectScreenState extends State<StudentsSelectScreen> {
  final _students = const [
    _Student(id: 's1', name: 'Marlon'),
    _Student(id: 's2', name: 'Paolo'),
    _Student(id: 's3', name: 'Saul'),
    _Student(id: 's4', name: 'Lucía'),
  ];

  final Set<String> _selected = {};
  String _q = '';
  bool _selectAll = false;

  List<_Student> get _filtered {
    if (_q.trim().isEmpty) return _students;
    final q = _q.toLowerCase();
    return _students.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  void _toggleAll(bool v) {
    setState(() {
      _selectAll = v;
      _selected
        ..clear()
        ..addAll(v ? _filtered.map((e) => e.id) : const <String>{});
    });
  }

  void _toggleOne(String id) {
    setState(() {
      if (_selected.remove(id) == false) _selected.add(id);
      final filteredIds = _filtered.map((e) => e.id).toSet();
      _selectAll =
          filteredIds.isNotEmpty && filteredIds.difference(_selected).isEmpty;
    });
  }

  Future<void> _goPickActivities() async {
    final picked = await Navigator.of(context).push<List<String>>(
      noAnimRoute(const ActivitiesPickerScreen()),
    );

    if (!mounted || picked == null || picked.isEmpty) return;

    // TODO: Llamar a tu backend para asignar: studentIds=_selected, activityIds=picked
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Asignadas ${picked.length} actividad(es) a ${_selected.length} alumno(s).',
        ),
      ),
    );

    setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Elige alumnos'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: _selected.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.06),
              child: FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: const Color(0xFF141F17),
                onPressed: _goPickActivities,
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Elegir estudiantes'),
              ),
            ),
      body: Column(
        children: [
          // Buscar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: TextField(
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
              cursorColor: Colors.white70,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Buscar alumno',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: AppTheme.blackLight,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon:
                    const Icon(Icons.search_rounded, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0)),
                ),
              ),
            ),
          ),

          // Seleccionar todo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: (v) => _toggleAll(v ?? false),
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text('Seleccionar todo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_selected.length} seleccionados',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final s = filtered[i];
                final sel = _selected.contains(s.id);
                return InkWell(
                  onTap: () => _toggleOne(s.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.blackLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? AppTheme.primaryColor : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Checkbox(
                          value: sel,
                          onChanged: (_) => _toggleOne(s.id),
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Student {
  final String id;
  final String name;
  const _Student({required this.id, required this.name});
}
