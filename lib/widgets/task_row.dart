import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/widgets.dart';

class TaskRow extends StatelessWidget {
  final String label;
  final int coins;
  final bool checked;
  const TaskRow(
      {super.key,
      required this.label,
      required this.coins,
      required this.checked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: checked ? AppTheme.primaryColor : AppTheme.black,
            shape: BoxShape.circle,
          ),
          child: Icon(
            checked ? Icons.check : Icons.circle_outlined,
            color: checked ? Colors.white : AppTheme.black,
            size: checked ? 28 : 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: checked ? AppTheme.grey : AppTheme.black,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: monedas(coins),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
