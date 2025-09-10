import 'package:flutter/material.dart';

PageRoute<T> noAnimRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    opaque: true, // tapa por completo la anterior
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}
