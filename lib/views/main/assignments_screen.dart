// lib/views/main/assignments_screen.dart
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  Future<void> _tasksThenStudents(BuildContext context) async {
    // 1) Elegir actividades
    final actIds = await Navigator.of(context).pushNamed('activities/picker')
        as List<String>?;

    if (actIds == null || actIds.isEmpty) return;

    // 2) Elegir alumnos
    final studentIds = await Navigator.of(context).pushNamed('students/select')
        as List<String>?;

    if (studentIds == null || studentIds.isEmpty) return;

    // TODO: llamada real a backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Asignadas ${actIds.length} actividades a ${studentIds.length} alumnos.',
        ),
      ),
    );
  }

  Future<void> _studentsThenTasks(BuildContext context) async {
    // 1) Elegir alumnos
    final studentIds = await Navigator.of(context).pushNamed('students/select')
        as List<String>?;
    if (studentIds == null || studentIds.isEmpty) return;

    // 2) Elegir actividades
    final actIds = await Navigator.of(context)
        .pushNamed<List<String>>('activities/picker');
    if (actIds == null || actIds.isEmpty) return;

    // TODO: llamada real a backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Asignadas ${actIds.length} actividades a ${studentIds.length} alumnos.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent, // 👈 importante para evitar “flash”
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asignaciones',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      )),
              const SizedBox(height: 18),
              _ActionCard(
                icon: Icons.task_alt_rounded,
                title: 'Tareas → Alumnos',
                subtitle:
                    'Elige una o varias actividades y luego selecciona a quién asignarlas.',
                onTap: () => _tasksThenStudents(context),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.group_rounded,
                title: 'Alumnos → Tareas',
                subtitle:
                    'Selecciona primero los alumnos y luego qué actividades asignar.',
                onTap: () => _studentsThenTasks(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.blackLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
              ),
              child: Icon(icon, color: Color(0xFF141F17)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
