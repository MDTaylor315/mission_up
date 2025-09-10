import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/widgets.dart';

class TaskCard extends StatelessWidget {
  final String name;
  final String subtitle;

  /// Para estado normal/seleccionado
  final int coins;

  /// Estado visual
  final bool selected;
  final bool request;

  /// Acciones si [request] == true
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const TaskCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.coins,
  })  : selected = false,
        request = false,
        onAccept = null,
        onReject = null;

  const TaskCard.selected({
    super.key,
    required this.name,
    required this.subtitle,
    required this.coins,
  })  : selected = true,
        request = false,
        onAccept = null,
        onReject = null;

  const TaskCard.request({
    super.key,
    required this.name,
    required this.subtitle,
    this.onAccept,
    this.onReject,
  })  : coins = 0,
        selected = false,
        request = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
        ],
        border:
            selected ? Border.all(color: AppTheme.coinsColor, width: 2) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // avatar círculo verde
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),

          // nombre + progreso
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
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

          // zona derecha: monedas o acciones (solicitud)
          if (!request)
            monedas(coins)
          else
            Row(
              children: [
                IconButton(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_rounded,
                      color: AppTheme.coinsColor),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // splashRadius: 16, // opcional
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.coinsColor),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // splashRadius: 16, // opcional
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
