import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/data/services/auth_provider.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _incomeCtrl;
  bool _loading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _incomeCtrl = TextEditingController(
        text: user?.monthlyIncome != null
            ? user!.monthlyIncome.toString()
            : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            monthlyIncome: _incomeCtrl.text.isEmpty
                ? null
                : double.tryParse(_incomeCtrl.text),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil atualizado com sucesso!'),
            backgroundColor: CashlyColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: CashlyColors.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CashlyColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta',
            style: TextStyle(color: CashlyColors.foreground)),
        content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(color: CashlyColors.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: CashlyColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair',
                style: TextStyle(color: CashlyColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Configurações',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: CashlyColors.foreground,
                          letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Gerencie sua conta e preferências',
                      style: TextStyle(
                          fontSize: 13, color: CashlyColors.mutedForeground)),
                ],
              ),
            ),
            _buildTabBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: [
                  _buildProfileTab(user),
                  _buildPrefsTab(user),
                  _buildSecurityTab(),
                ][_selectedTab],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Perfil', 'Preferências', 'Segurança'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: CashlyColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CashlyColors.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == _selectedTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient:
                        selected ? CashlyColors.gradientPrimary : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : CashlyColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileTab(user) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Avatar
        Center(
          child: Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: CashlyColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: CashlyColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? 'U',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(user?.name ?? '',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CashlyColors.foreground)),
        Text(user?.email ?? '',
            style: const TextStyle(
                fontSize: 13, color: CashlyColors.mutedForeground)),
        const SizedBox(height: 24),
        CashlyCard(
          child: Column(
            children: [
              CashlyTextField(
                label: 'Nome',
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
              CashlyTextField(
                label: 'Email',
                controller:
                    TextEditingController(text: user?.email ?? ''),
                enabled: false,
              ),
              const SizedBox(height: 16),
              CashlyTextField(
                label: 'Telefone',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CashlyTextField(
                label: 'Renda mensal (R\$)',
                controller: _incomeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: _loading ? null : _save,
                isLoading: _loading,
                height: 48,
                child: const Text('Salvar alterações',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPrefsTab(user) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CashlyCard(
          child: Column(
            children: [
              _prefRow(
                icon: Icons.attach_money_rounded,
                title: 'Moeda',
                subtitle: user?.currency ?? 'BRL',
              ),
              const Divider(
                  color: CashlyColors.border, height: 24),
              _prefRow(
                icon: Icons.dark_mode_rounded,
                title: 'Tema',
                subtitle: 'Dark mode (padrão)',
              ),
              const Divider(
                  color: CashlyColors.border, height: 24),
              _prefSwitchRow(
                icon: Icons.notifications_rounded,
                title: 'Notificações por email',
                subtitle: 'Receba resumos semanais',
                value: true,
                onChanged: (_) {},
              ),
              const Divider(
                  color: CashlyColors.border, height: 24),
              _prefSwitchRow(
                icon: Icons.credit_card_rounded,
                title: 'Alertas de fatura',
                subtitle: 'Avise antes do vencimento',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        CashlyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Segurança',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CashlyColors.foreground)),
              const SizedBox(height: 8),
              const Text(
                'A alteração de senha pelo app ainda não está disponível. Você pode usar o fluxo de "Esqueci minha senha".',
                style: TextStyle(
                    fontSize: 13, color: CashlyColors.mutedForeground),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded,
                      color: CashlyColors.danger, size: 18),
                  label: const Text('Sair da conta',
                      style: TextStyle(
                          color: CashlyColors.danger,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: CashlyColors.danger),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _prefRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CashlyColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: CashlyColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CashlyColors.foreground)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: CashlyColors.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prefSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CashlyColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: CashlyColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CashlyColors.foreground)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: CashlyColors.mutedForeground)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: CashlyColors.primaryLight,
          activeTrackColor: CashlyColors.primary.withOpacity(0.3),
          inactiveTrackColor: CashlyColors.border,
          inactiveThumbColor: CashlyColors.mutedForeground,
        ),
      ],
    );
  }
}
