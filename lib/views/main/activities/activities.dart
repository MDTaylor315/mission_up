// lib/views/main/activities_screen.dart
import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/activities_controller.dart';
import 'package:mission_up/providers/actividad_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/widgets/widgets.dart';
import 'package:provider/provider.dart'; // <- para monedas()

// ✅ 1. Convertimos a StatefulWidget para usar el Controller
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  // ✅ 2. Creamos instancias para el controller y el controlador de texto
  final _controller = ActivitiesController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Usamos 'addPostFrameCallback' para asegurar que el contexto esté disponible
    // cuando llamemos al provider. Es la forma más segura de hacerlo en initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtenemos las instancias de nuestros servicios/providers.
      // Usamos 'read' en lugar de 'watch' porque solo estamos llamando a una acción,
      // no necesitamos escuchar cambios aquí.
      final actividadesProvider = context.read<ActividadesProvider>();

      // ¡Aquí está la llamada que faltaba!
      // Le pedimos al provider que cargue los alumnos activos.
      // No pasamos fecha porque esta pantalla necesita a TODOS los alumnos aceptados.
      actividadesProvider.fetchActividades();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // ✅ Título con ícono para mayor impacto visual
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Confirmar Eliminación',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          content: const Text(
            '¿Estás seguro de que quieres eliminar esta actividad? Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            // ✅ Botón 'Cancelar' sutil para no distraer
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),

            // ✅ Botón 'Eliminar' con fondo rojo para que sea la acción principal
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors
                    .red[800], // Un rojo oscuro que se ve bien en fondos negros
                foregroundColor: Colors.white, // Color del texto
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el AuthService para isAdmin
    final authService = context.watch<AuthService>();
    final isAdmin = authService.currentUser?.isAdmin ?? false;

    // Envolvemos solo esta pantalla con el provider de actividades
    return Scaffold(
      extendBody: true,
      floatingActionButton: !isAdmin ? null : _buildFab(context),
      body: Consumer<ActividadesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          return SafeArea(
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _SearchBox(
                        controller: _searchController,
                        hint: 'Buscar Tareas, Premios...',
                        onChanged: (texto) {
                          provider.updateSearchQuery(texto);
                        },
                      ),
                    ),

                  // ✅ GENERACIÓN DINÁMICA DE SECCIONES
                  // Usamos un bucle para crear cada sección a partir de los grupos
                  ...provider.gruposMostrados.map((grupo) {
                    // Si un grupo queda sin actividades después de filtrar, no lo mostramos.
                    if (grupo.actividades.isEmpty) {
                      return const SizedBox.shrink(); // Widget vacío
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(grupo.tipoDescripcion),
                        const SizedBox(height: 10),
                        // Creamos un ListView para las actividades de este grupo
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: grupo.actividades.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final actividad = grupo.actividades[index];
                            return _ActivityTile(
                              label: actividad.titulo,
                              coins: actividad.puntaje,
                              onTap: () {
                                // Al tocar, navegamos a la ruta de edición
                                Navigator.of(context).pushNamed(
                                  'activity/edit',
                                  // Pasamos tanto el provider como la actividad específica que se tocó
                                  arguments: {
                                    'provider':
                                        context.read<ActividadesProvider>(),
                                    'actividad': actividad,
                                  },
                                );
                              },
                              onDelete: () async {
                                final confirmed =
                                    await _showConfirmDialog(context);
                                if (confirmed == true && mounted) {
                                  await _controller.deleteActivity(
                                    context: context,
                                    activityId: actividad.id.toInt(),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 22), // Espacio entre secciones
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper para construir el FAB
  Widget _buildFab(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.06, right: 6.0),
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onPressed: () {
            // ✅ 2. Cuando se toque el fondo, quita el foco
            FocusScope.of(context).unfocus();

            Navigator.of(context).pushNamed(
              'activity/create',
              // ✅ Y le pasamos el provider como un argumento
              arguments: context.read<ActividadesProvider>(),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
    ;
  }
}

class _SearchBox extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged; // AÑADE ESTO

  final ValueChanged<String>? onSubmitted;
  const _SearchBox({
    required this.hint,
    this.onSubmitted,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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
  final VoidCallback? onDelete;

  const _ActivityTile(
      {required this.label, required this.coins, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      onLongPress: onDelete,
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
