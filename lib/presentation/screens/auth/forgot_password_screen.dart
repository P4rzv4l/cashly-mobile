import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/core/api/api_client.dart';
import 'package:cashly/core/constants/api_constants.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        ApiConstants.forgotPassword,
        data: {'email': _emailCtrl.text.trim()},
      );
      setState(() => _sent = true);
    } catch (_) {
      setState(() => _sent = true); // Show success anyway (security)
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: CashlyColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: CashlyColors.success, size: 36),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verifique seu email',
          style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700,
            color: CashlyColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enviamos um link para você redefinir sua senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: CashlyColors.mutedForeground),
        ),
        const SizedBox(height: 32),
        GradientButton(
          onPressed: () => context.go('/login'),
          child: const Text('Voltar para o login',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: CashlyColors.foreground, size: 20),
        ),
        const SizedBox(height: 40),
        const Text(
          'Esqueci minha\nsenha',
          style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w800,
            color: CashlyColors.foreground, height: 1.1, letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vamos enviar um link de redefinição.',
          style: TextStyle(fontSize: 14, color: CashlyColors.mutedForeground),
        ),
        const SizedBox(height: 36),
        CashlyTextField(
          label: 'Email',
          hint: 'voce@email.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        GradientButton(
          onPressed: _loading ? null : _submit,
          isLoading: _loading,
          child: const Text('Enviar link',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
    );
  }
}
