import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/data/services/auth_provider.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CashlyColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 48),
                const Text(
                  'Entrar na\nsua conta',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: CashlyColors.foreground,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acesse seu painel financeiro',
                  style: TextStyle(
                    fontSize: 14,
                    color: CashlyColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 36),
                CashlyTextField(
                  label: 'Email',
                  hint: 'voce@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o email';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CashlyTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                      color: CashlyColors.mutedForeground,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/esqueci-senha'),
                    child: const Text(
                      'Esqueci a senha',
                      style: TextStyle(color: CashlyColors.primaryLight, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  onPressed: _loading ? null : _submit,
                  isLoading: _loading,
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tem conta? ',
                      style: TextStyle(
                          color: CashlyColors.mutedForeground, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/cadastro'),
                      child: const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: CashlyColors.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: CashlyColors.gradientPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          'Cashly',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: CashlyColors.foreground,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
