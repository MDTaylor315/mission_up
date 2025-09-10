// lib/views/main/activities_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/widgets.dart'; // monedas()

class ActivitiesPickerScreen extends StatefulWidget {
  const ActivitiesPickerScreen({super.key});

  @override
  State<ActivitiesPickerScreen> createState() => _ActivitiesPickerScreenState();
}

class _ActivitiesPickerScreenState extends State<ActivitiesPickerScreen> {
  final _tasks = const [
    _Activity(id: 't1', label: 'Participar en clase', coins: 3),
    _Activity(id: 't2', label: 'Hacer la tarea', coins: 3),
    _Activity(id: 't3', label: 'Tender la cama', coins: 3),
  ];
  final _rewards = const [
    _Activity(id: 'r1', label: 'Salida al cine', coins: 3),
  ];
  final _punishments = const [
    _Activity(id: 'c1', label: 'Conducta', coins: 10),
  ];

  final Set<String> _selected = {};
  String _q = '';

  List<_Activity> _filter(List<_Activity> items) {
    if (_q.trim().isEmpty) return items;
    final q = _q.toLowerCase();
    return items.where((e) => e.label.toLowerCase().contains(q)).toList();
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.remove(id) == false) _selected.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filter(_tasks);
    final rewards = _filter(_rewards);
    final punish = _filter(_punishments);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Elige actividades'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Buscar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: TextField(
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
              cursorColor: Colors.white70,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Buscar actividad',
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section('Tareas'),
                  const SizedBox(height: 10),
                  ...tasks.map((e) => _tile(e)),
                  const SizedBox(height: 22),
                  _Section('Premios'),
                  const SizedBox(height: 10),
                  ...rewards.map((e) => _tile(e)),
                  const SizedBox(height: 22),
                  _Section('Castigos'),
                  const SizedBox(height: 10),
                  ...punish.map((e) => _tile(e)),
                ],
              ),
            ),
          ),

          // Confirmar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: const Color(0xFF141F17),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selected.toList()),
                  child: Text('Elegir ${_selected.length} actividad(es)'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(_Activity a) {
    final selected = _selected.contains(a.id);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _toggle(a.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.blackLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                a.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppTheme.primaryColor : Colors.white54,
                size: 20,
              ),
            ),
            monedas(a.coins),
          ],
        ),
      ),
    );
  }
}

class _Activity {
  final String id;
  final String label;
  final int coins;
  const _Activity({required this.id, required this.label, required this.coins});
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
    );
  }
}
