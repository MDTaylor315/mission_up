// lib/views/main/activities_screen.dart
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/widgets.dart'; // <- para monedas()

class ActivitiesScreen extends StatelessWidget {
  final bool isAdmin; // 👈 Nuevo parámetro

  const ActivitiesScreen(
      {super.key, this.isAdmin = false}); // 👈 Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Deja transparente si usas un gradiente global en el Scaffold raíz
      extendBody: true,
      floatingActionButton: !isAdmin
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.06,
                    right: 6.0),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('activity/create'),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  isAdmin ? 'Actividades' : 'Canjea tus puntos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 14),

                // Buscador
                if (isAdmin)
                  Column(
                    children: [
                      _SearchBox(
                        hint: 'Buscar',
                        onSubmitted: (q) {
                          // TODO: filtrar lista
                        },
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),

                // Sección: Tareas
                const _SectionTitle('Tareas'),
                const SizedBox(height: 10),
                const _ActivityTile(label: 'Participar en clase', coins: 3),
                const SizedBox(height: 12),
                const _ActivityTile(label: 'Hacer la tarea', coins: 3),
                const SizedBox(height: 12),
                const _ActivityTile(label: 'Tender la cama', coins: 3),

                const SizedBox(height: 22),

                // Sección: Premios
                const _SectionTitle('Premios'),
                const SizedBox(height: 10),
                const _ActivityTile(label: 'Salida al cine', coins: 3),

                const SizedBox(height: 22),

                // Sección: Castigos
                const _SectionTitle('Castigos'),
                const SizedBox(height: 10),
                const _ActivityTile(label: 'Conducta', coins: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchBox({required this.hint, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      cursorColor: Colors.white70,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(.9),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: AppTheme.blackLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon:
            const Icon(Icons.search_rounded, color: Colors.white70, size: 24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(0)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

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

class _ActivityTile extends StatelessWidget {
  final String label;
  final int coins;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.label,
    required this.coins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.blackLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            monedas(coins), // usa tu helper para número + monedas
          ],
        ),
      ),
    );
  }
}
