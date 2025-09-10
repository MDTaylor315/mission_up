import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/task_row.dart';
import 'package:mission_up/widgets/widgets.dart';

class TasksSlide extends StatelessWidget {
  const TasksSlide();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * .18),
            child: Text(
              'Pequeñas tareas\nGrandes hábitos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.1,
                  ),
            ),
          ),
          const SizedBox(height: 28),
          const TaskRow(label: 'Hacer la cama', coins: 2, checked: false),
          const SizedBox(height: 14),
          const TaskRow(label: 'Participar en clase', coins: 3, checked: false),
          const SizedBox(height: 14),
          const TaskRow(label: 'Limpiar el cuarto', coins: 1, checked: true),
          const Spacer(),
        ],
      ),
    );
  }
}
