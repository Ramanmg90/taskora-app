import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context
          .read<AuthProvider>()
          .login(_usernameCtrl.text, _passwordCtrl.text);
    } catch (e) {
      setState(() => _error = _clean(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').trim();

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeSlideIn(
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: NeonPalette.brand,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: NeonPalette.violet.withOpacity(0.45),
                              blurRadius: 36,
                              spreadRadius: -4,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ShaderMask(
                        shaderCallback: (r) =>
                            NeonPalette.brand.createShader(r),
                        child: const Text(
                          'تسکورا',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'وارد شو و کارهایت را روشن کن',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.inkMuted, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  delayMs: 120,
                  child: GlassCard(
                    radius: AppRadius.lg,
                    glow: NeonPalette.indigo,
                    glowOpacity: 0.20,
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'نام کاربری',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'نام کاربری را وارد کنید'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'رمز عبور',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 19,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'رمز عبور را وارد کنید'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            child: _error == null
                                ? const SizedBox(height: 0, width: double.infinity)
                                : Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeonPalette.rose
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xs),
                                        border: Border.all(
                                          color: NeonPalette.rose
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: NeonPalette.rose,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _error!,
                                              style: const TextStyle(
                                                color: NeonPalette.rose,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          NeonButton(
                            label: 'ورود',
                            icon: Icons.login_rounded,
                            loading: _loading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  delayMs: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'حساب نداری؟',
                        style: TextStyle(color: t.inkMuted, fontSize: 12.5),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .push(neonRoute(const RegisterScreen())),
                        child: const Text('ساخت حساب جدید'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
