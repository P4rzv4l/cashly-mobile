import 'package:cashly/presentation/widgets/common/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';
import 'package:cashly/data/models/models.dart';
import 'package:cashly/data/services/data_providers.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class ReservesScreen extends ConsumerWidget {
  const ReservesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservesAsync = ref.watch(reservesProvider);

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
                  Text('Reservas',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: CashlyColors.foreground,
                          letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Seu dinheiro guardado',
                      style: TextStyle(
                          fontSize: 13, color: CashlyColors.mutedForeground)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: CashlyColors.primaryLight,
                backgroundColor: CashlyColors.surface,
                onRefresh: () async => ref.invalidate(reservesProvider),
                child: reservesAsync.when(
                  loading: () => _buildLoading(),
                  error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(reservesProvider),
                ),
                  data: (reserves) {
                    final total = reserves.fold<double>(
                        0, (sum, r) => sum + (r as Reserve).currentAmount);
                    final targetTotal = reserves.fold<double>(
                        0, (sum, r) => sum + (r as Reserve).targetAmount);
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      children: [
                        _buildSummaryCard(total, targetTotal),
                        const SizedBox(height: 16),
                        if (reserves.isEmpty)
                          _buildEmpty()
                        else
                          ...reserves.asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _ReserveCard(reserve: e.value),
                                ),
                              ),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, double targetTotal) {
    return GradientCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total guardado',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  CashlyFormat.brl(total),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Meta total',
                        style:
                            TextStyle(fontSize: 10, color: Colors.white70)),
                    Text(CashlyFormat.compactBrl(targetTotal),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CashlyShimmer(height: 100, borderRadius: 20),
        const SizedBox(height: 16),
        ...List.generate(
            3,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CashlyShimmer(height: 130, borderRadius: 20),
                )),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🐷', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Nenhuma reserva criada',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CashlyColors.foreground)),
          ],
        ),
      ),
    );
  }
}

class _ReserveCard extends StatelessWidget {
  final Reserve reserve;
  const _ReserveCard({required this.reserve});

  static const _typeLabels = {
    'emergency': 'Emergência',
    'opportunity': 'Oportunidade',
    'seasonal': 'Sazonal',
  };

  @override
  Widget build(BuildContext context) {
    final pct = reserve.progressPercent;

    return CashlyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: CashlyColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.savings_rounded,
                color: CashlyColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(reserve.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CashlyColors.foreground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (reserve.type != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: CashlyColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _typeLabels[reserve.type] ?? reserve.type!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: CashlyColors.mutedForeground),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CashlyFormat.brl(reserve.currentAmount),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: CashlyColors.foreground,
                      letterSpacing: -0.3),
                ),
                Text(
                  'Meta ${CashlyFormat.brl(reserve.targetAmount)}',
                  style: const TextStyle(
                      fontSize: 12, color: CashlyColors.mutedForeground),
                ),
                const SizedBox(height: 10),
                CashlyProgress(value: pct, height: 7),
                const SizedBox(height: 4),
                Text(
                  '${pct.toInt()}% da meta',
                  style: const TextStyle(
                      fontSize: 10, color: CashlyColors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
