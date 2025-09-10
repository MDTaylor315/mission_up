// lib/onboarding_flow.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/views/intro/intro_pages/intro_1.dart';
import 'package:mission_up/views/intro/intro_pages/intro_2.dart';
import 'package:mission_up/views/intro/intro_pages/intro_3.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});
  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  static const _dotsLength = 3; // 3 puntos como en tu diseño
  static const _interval = Duration(seconds: 2);
  static const _anim = Duration(milliseconds: 450);
  // Agrega / quita vistas aquí y TODO se actualiza solo (pase + puntos)
  final List<Widget> _slides = const [
    TasksSlide(),
    RewardsSlide(),
    SuperviseSlide(),
  ];

  late final PageController _controller;
  late Timer _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // arrancamos en un índice grande para permitir “solo hacia la derecha”
    _page = 1000 * _dotsLength;
    _controller = PageController(initialPage: _page);

    _timer = Timer.periodic(_interval, (_) {
      _page += 1;
      if (!mounted) return;
      _controller.animateToPage(
        _page,
        duration: _anim,
        curve: Curves.easeIn,
      );
      // setState no es necesario aquí porque onPageChanged actualizará el estado,
      // pero nos aseguramos si la animación es instantánea
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _slides.length;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Builder para “infinito” hacia la derecha
            PageView.builder(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              // ← dinámico según la cantidad de slides
              itemBuilder: (_, i) => _slides[i % total],
            ),

            // Puntos también dinámicos
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: Center(
                child: _Dots(
                  activeIndex: _page % total,
                  length: total,
                ),
              ),
            ),

            const Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _BottomButtons(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Widgets compartidos
class _Dots extends StatelessWidget {
  final int activeIndex;
  final int length;
  const _Dots({required this.activeIndex, this.length = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                active ? AppTheme.primaryColor : Colors.white.withOpacity(.7),
          ),
        );
      }),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: const Color.fromARGB(255, 199, 223, 206),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/login");
            },
            child: const Text('Soy Tutor',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3A3F3B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/guest");
            },
            child: const Text('Soy Alumno',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
