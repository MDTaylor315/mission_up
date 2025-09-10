// lib/views/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mission_up/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  static const _orange = Color(0xFFFFA754); // flecha
  static const _registerBtn = Color(0xFFF0B657); // botón Registrarme

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      // TODO: lógica real de registro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creando cuenta...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: _orange),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),

                        // Título
                        Center(
                          child: Text(
                            'Registrarme',
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

                        const SizedBox(height: 20),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/img/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Formulario
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                decoration: _decor('Nombres y Apellidos'),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Ingresa tu nombre'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailCtrl,
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
                                textInputAction: TextInputAction.next,
                                obscureText: _obscure1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                decoration: _decor(
                                  'Contraseña',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure1 = !_obscure1),
                                    icon: Icon(
                                      _obscure1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white.withOpacity(.9),
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mínimo 6 caracteres'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _pass2Ctrl,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscure2,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                decoration: _decor(
                                  'Repetir Contraseña',
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure2 = !_obscure2),
                                    icon: Icon(
                                      _obscure2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white.withOpacity(.9),
                                    ),
                                  ),
                                ),
                                validator: (v) => (v != _passCtrl.text)
                                    ? 'Las contraseñas no coinciden'
                                    : null,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón Registrarme (naranja)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _registerBtn,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'Registrarme',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

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
                              child: Text(
                                'o',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(.2),
                                    thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 24),

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
