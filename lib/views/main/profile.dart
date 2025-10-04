import 'package:flutter/material.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/profile_controller.dart'; // ✅ 1. Importa tu controller
import 'package:mission_up/providers/auth_provider.dart'; // ✅ 2. Importa el AuthService
import 'package:provider/provider.dart'; // ✅ 3. Importa Provider

// ✅ 4. Convertimos a StatefulWidget para poder usar nuestro ProfileController
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✅ 5. Creamos una instancia del ProfileController
  final _controller = ProfileController();

  @override
  Widget build(BuildContext context) {
    // ✅ 6. Obtenemos la instancia de AuthService usando context.watch
    //    Usamos 'watch' para que la UI se reconstruya si los datos del usuario cambian.
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const SizedBox(height: 8),
              Text(
                'Perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
              ),

              const SizedBox(height: 24),

              // Avatar + nombre + email
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      // TODO: Aquí podrías mostrar el avatar del usuario si lo tienes
                      // child: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl ?? '')),
                    ),
                    const SizedBox(height: 14),
                    // ✅ 7. Mostramos los datos reales del usuario
                    Text(
                      user?.nombre ?? 'Usuario', // Muestra el nombre real
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Muestra el correo o el username
                      user?.correo ?? user?.telefono ?? 'Sin contacto',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Opciones
              _MenuTile(
                label: 'Información',
                icon: Icons.person_outline_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _MenuTile(
                label: 'Contraseña',
                icon: Icons.visibility_outlined,
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _MenuTile(
                label: 'Notificaciones',
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _MenuTile(
                label: 'Cerrar Sesión',
                icon: Icons.logout_rounded,
                // ✅ 8. Conectamos el botón para que llame al controller
                onTap: () {
                  _controller.logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2F33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
