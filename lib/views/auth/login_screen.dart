// lib/views/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;

  LoginController controller = LoginController();

  static const _orange = Color(0xFFFFA754); // flecha y link

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();

    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  InputDecoration _decor(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(.95),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: AppTheme.blackLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0)),
      ),
    );
  }

  Future<void> _submit() async {
    // 1. Valida el formulario
    if (!_formKey.currentState!.validate()) return;

    // Captura cuál nodo tiene el foco AHORA MISMO.
    final currentFocus = FocusManager.instance.primaryFocus;

    // Oculta el teclado de forma inmediata.
    currentFocus?.unfocus();

    // 3. Llama al controller.
    final success = await controller.login(
      context,
      contacto: _userCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      print('Login exitoso, esperando la navegación automática...');
    } else {
      print('El login falló. El usuario ya vio el diálogo de error.');
      currentFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // explícito (por si lo cambiaste en otro lado)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),

          // ⬇️ Clave: LayoutBuilder + SingleChildScrollView + ConstrainedBox
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset =
                  MediaQuery.of(context).viewInsets.bottom; // alto del teclado

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  // IntrinsicHeight permite que los Spacer funcionen con scroll
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back (sin márgenes extra si no los quieres)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Color(0xFFFFA754)),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),

                        // Título
                        Center(
                          child: Text(
                            'Iniciar Sesión',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/img/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Formulario
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _userCtrl,
                                focusNode: _userFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                decoration: _decor('Email o Celular'),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Ingresa tu email o celular'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passCtrl,
                                focusNode: _passFocus,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscure,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                decoration: _decor(
                                  'Contraseña',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white.withOpacity(.9),
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu contraseña'
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        // Olvidé contraseña
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: _orange,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Olvide Contraseña',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),

                        SizedBox(height: 10),
                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor:
                                  const Color.fromARGB(255, 199, 223, 206),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () async {
                              await _submit();
                            },
                            child: const Text('Iniciar Sesión',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Botón registrarme (naranja claro)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF0B657),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                "/register",
                              );
                            },
                            child: const Text('Registrarme',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),

                        SizedBox(height: 30),
                        // Separador "o"
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(.2),
                                    thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('o',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.85),
                                      fontWeight: FontWeight.w700)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(.2),
                                    thickness: 1)),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Social buttons
                        Row(
                          children: [
                            Expanded(
                                child: _SocialBtn.google(onPressed: () {})),
                            const SizedBox(width: 14),
                            Expanded(
                                child: _SocialBtn.facebook(onPressed: () {})),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final Color bg;
  final Color fg;
  final Widget icon;
  final String label;

  const _SocialBtn._({
    required this.onPressed,
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });

  factory _SocialBtn.google({required VoidCallback onPressed}) => _SocialBtn._(
        onPressed: onPressed,
        bg: Colors.white,
        fg: Colors.black87,
        icon: SvgPicture.asset(
          'assets/icons/google.svg',
          width: 22,
          height: 22,
        ),
        label: 'Google',
      );

  factory _SocialBtn.facebook({required VoidCallback onPressed}) =>
      _SocialBtn._(
        onPressed: onPressed,
        bg: const Color(0xFF2B57E8),
        fg: Colors.white,
        icon: SvgPicture.asset(
          'assets/icons/facebook.svg',
          width: 22,
          height: 22,
        ),
        label: 'Facebook',
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
