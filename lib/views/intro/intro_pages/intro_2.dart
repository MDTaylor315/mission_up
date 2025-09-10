import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/widgets.dart';

/// ---------- Slide 2: Recompensas
class RewardsSlide extends StatelessWidget {
  const RewardsSlide();
  @override
  Widget build(BuildContext context) {
    final rewards = const <({String title, int cost})>[
      (title: 'Noche de Cine', cost: 25),
      (title: 'Comprar Lego', cost: 100),
      (title: 'Noche de Pizza', cost: 150),
      (title: 'Salida a jugar', cost: 10),
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
              'Motiva con\nrecompensas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.1,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemCount: rewards.length,
            itemBuilder: (_, i) => _RewardCard(
              title: rewards[i].title,
              cost: rewards[i].cost,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final int cost;
  const _RewardCard({required this.title, required this.cost});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const Spacer(),
          monedas(cost),
        ],
      ),
    );
  }
}
