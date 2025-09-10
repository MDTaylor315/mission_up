import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/tasks_card.dart';
import 'package:mission_up/widgets/widgets.dart'; // monedas(int)

class SuperviseSlide extends StatelessWidget {
  const SuperviseSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (name: 'Marlon', progress: '2/10 tareas realizadas', coins: 8),
      (name: 'Paolo', progress: '0/10 tareas realizadas', coins: 0),
      (name: 'Julio', progress: '10/10 tareas realizadas', coins: 17),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * .12),
            child: Text(
              'Supervisa a todos\ndesde tu celular',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.1,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TaskCard(
                    name: e.name, subtitle: e.progress, coins: e.coins),
              )),
          const Spacer(),
        ],
      ),
    );
  }
}
