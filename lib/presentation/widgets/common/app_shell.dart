import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.grid_view_rounded, label: 'Início', path: '/dashboard'),
    _TabItem(icon: Icons.swap_horiz_rounded, label: 'Transações', path: '/transacoes'),
    _TabItem(icon: Icons.credit_card_rounded, label: 'Cartões', path: '/cartoes'),
    _TabItem(icon: Icons.flag_rounded, label: 'Metas', path: '/metas'),
    _TabItem(icon: Icons.auto_awesome_rounded, label: 'IA', path: '/ia'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: CashlyColors.surface,
          border: Border(top: BorderSide(color: CashlyColors.border, width: 0.8)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = i == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(tab.path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? CashlyColors.primary.withOpacity(0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            tab.icon,
                            size: 22,
                            color: selected
                                ? CashlyColors.primaryLight
                                : CashlyColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? CashlyColors.primaryLight
                                : CashlyColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;
  const _TabItem({required this.icon, required this.label, required this.path});
}
