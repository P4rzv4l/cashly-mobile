import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/data/services/auth_provider.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            passwordConfirmation: _confirmCtrl.text,
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
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: CashlyColors.foreground, size: 20),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Criar sua\nconta',
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
                  'Comece a organizar suas finanças hoje',
                  style: TextStyle(fontSize: 14, color: CashlyColors.mutedForeground),
                ),
                const SizedBox(height: 32),
                CashlyTextField(
                  label: 'Nome',
                  hint: 'Como podemos te chamar?',
                  controller: _nameCtrl,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) return 'Nome muito curto';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CashlyTextField(
                  label: 'Email',
                  hint: 'voce@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || !v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CashlyTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CashlyTextField(
                  label: 'Confirmar senha',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  obscureText: true,
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Senhas não conferem';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                GradientButton(
                  onPressed: _loading ? null : _submit,
                  isLoading: _loading,
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem conta? ',
                      style: TextStyle(
                          color: CashlyColors.mutedForeground, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: const Text(
                        'Entrar',
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
}
