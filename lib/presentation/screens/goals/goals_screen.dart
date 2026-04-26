import 'package:cashly/presentation/widgets/common/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';
import 'package:cashly/data/models/models.dart';
import 'package:cashly/data/services/data_providers.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

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
                  Text('Metas',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: CashlyColors.foreground,
                          letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Acompanhe o progresso dos seus sonhos',
                      style: TextStyle(
                          fontSize: 13, color: CashlyColors.mutedForeground)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: CashlyColors.primaryLight,
                backgroundColor: CashlyColors.surface,
                onRefresh: () async => ref.invalidate(goalsProvider),
                child: goalsAsync.when(
                  loading: () => _buildLoading(),
                  error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(goalsProvider),
                ),
                  data: (goals) => goals.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          itemCount: goals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) =>
                              _GoalCard(goal: goals[i]),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(
          4,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: CashlyShimmer(height: 140, borderRadius: 20),
              )),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎯', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('Nenhuma meta criada',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CashlyColors.foreground)),
          SizedBox(height: 6),
          Text('Comece definindo seus objetivos financeiros',
              style:
                  TextStyle(fontSize: 13, color: CashlyColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final pct = goal.progressPercentage.clamp(0.0, 100.0);
    final done = goal.isCompleted;
    final barColor = done
        ? CashlyColors.success
        : pct > 60
            ? CashlyColors.primaryLight
            : CashlyColors.accent;

    return CashlyCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: CashlyColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: CashlyColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    goal.icon ?? '🎯',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CashlyColors.foreground)),
                    if (goal.targetDate != null) ...[
                      const SizedBox(height: 2),
                      Text('Prazo ${CashlyFormat.longDate(goal.targetDate!)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: CashlyColors.mutedForeground)),
                    ],
                  ],
                ),
              ),
              if (done)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CashlyColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Concluída',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CashlyColors.success),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CashlyFormat.brl(goal.currentAmount),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CashlyColors.foreground,
                    letterSpacing: -0.3),
              ),
              Text(
                CashlyFormat.brl(goal.targetAmount),
                style: const TextStyle(
                    fontSize: 14, color: CashlyColors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CashlyProgress(value: pct, color: barColor, height: 8),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${pct.toInt()}% concluído',
                  style: const TextStyle(
                      fontSize: 11, color: CashlyColors.mutedForeground)),
              Text(
                'Faltam ${CashlyFormat.brl(goal.remainingAmount.clamp(0, double.infinity))}',
                style: const TextStyle(
                    fontSize: 11, color: CashlyColors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
