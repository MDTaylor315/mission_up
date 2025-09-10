import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mission_up/app_theme.dart';

Widget monedas(int monedas,
    {MainAxisAlignment alignment = MainAxisAlignment.start}) {
  return Row(
    mainAxisAlignment: alignment,
    children: [
      // El número lo colocamos con un builder para poder usar coins dinámicos
      Text(monedas.toString(),
          style: TextStyle(
              color: AppTheme.coinsColor,
              fontWeight: FontWeight.w600,
              fontSize: 20)),
      SizedBox(
        width: 8,
      ),
      SvgPicture.asset('assets/icons/coins.svg', height: 20),
    ],
  );
}
