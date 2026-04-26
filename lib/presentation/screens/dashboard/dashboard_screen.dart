import 'package:cashly/presentation/widgets/common/error_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';
import 'package:cashly/data/models/models.dart';
import 'package:cashly/data/services/auth_provider.dart';
import 'package:cashly/data/services/data_providers.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: CashlyColors.primaryLight,
          backgroundColor: CashlyColors.surface,
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: dashAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(dashboardProvider),
                ),
            data: (data) => _buildContent(context, data, user),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Dashboard data, User? user) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(user)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildBalanceSection(data),
              const SizedBox(height: 24),
              _buildHealthAndForecast(data),
              const SizedBox(height: 24),
              _buildSpendingChart(data),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(data),
              const SizedBox(height: 24),
              _buildRecentTransactions(context, data),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user?.firstName ?? 'por aqui'} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CashlyColors.foreground,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Aqui está seu panorama financeiro de hoje.',
                  style: TextStyle(
                    fontSize: 13,
                    color: CashlyColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _hidden = !_hidden),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CashlyColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CashlyColors.border),
              ),
              child: Icon(
                _hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                size: 18,
                color: CashlyColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(Dashboard data) {
    return Column(
      children: [
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo total',
                style: TextStyle(
                    fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                _hidden ? 'R\$ •••••' : CashlyFormat.brl(data.balance.totalBalance),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _balancePill(
                    '↑ Entradas',
                    CashlyFormat.brl(data.balance.monthlyIncome),
                    CashlyColors.success,
                  ),
                  const SizedBox(width: 8),
                  _balancePill(
                    '↓ Saídas',
                    CashlyFormat.brl(data.balance.monthlyExpense),
                    Colors.white60,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Disponível',
                value: data.balance.availableBalance,
                hidden: _hidden,
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Comprometido',
                value: data.balance.committedBalance,
                hidden: _hidden,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _balancePill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildHealthAndForecast(Dashboard data) {
    final health = data.financialHealth;
    final forecast = data.endOfMonthForecast;
    if (health == null && forecast == null) return const SizedBox.shrink();
    final score = health?.score ?? 0;
    final healthColor = score >= 70
        ? CashlyColors.success
        : score >= 40
            ? CashlyColors.warning
            : CashlyColors.danger;

    return Row(
      children: [
        Expanded(
          child: CashlyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saúde financeira',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CashlyColors.foreground)),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: CashlyColors.border,
                        valueColor: AlwaysStoppedAnimation(healthColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: healthColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  health?.status ?? '',
                  style: TextStyle(
                      fontSize: 12,
                      color: healthColor,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CashlyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Previsão fim do mês',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CashlyColors.foreground)),
                const SizedBox(height: 8),
                Text(
                  '${(forecast?.daysRemaining ?? 0)} dias',
                  style: const TextStyle(
                      fontSize: 11, color: CashlyColors.mutedForeground),
                ),
                const SizedBox(height: 8),
                Text(
                  _hidden
                      ? 'R\$ •••••'
                      : CashlyFormat.brl(forecast?.projectedEomBalance ?? 0),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CashlyColors.foreground,
                  ),
                ),
                const SizedBox(height: 10),
                _forecastRow('Entradas', forecast?.remainingIncome ?? 0),
                _forecastRow('Saídas', forecast?.remainingExpenses ?? 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _forecastRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: CashlyColors.mutedForeground)),
          Text(CashlyFormat.compactBrl(value),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: CashlyColors.foreground)),
        ],
      ),
    );
  }

  Widget _buildSpendingChart(Dashboard data) {
    if (data.monthlyChart.isEmpty) return const SizedBox.shrink();
    final points = data.monthlyChart;

    return CashlyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Entradas e saídas', subtitle: 'Últimos meses'),
          const SizedBox(height: 8),
          Row(
            children: [
              _chartLegend(CashlyColors.primaryLight, 'Entradas'),
              const SizedBox(width: 16),
              _chartLegend(CashlyColors.accent, 'Saídas'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: CashlyColors.border,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= points.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            points[i].label,
                            style: const TextStyle(
                                fontSize: 10,
                                color: CashlyColors.mutedForeground),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(points.length, (i) {
                  final p = points[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: p.income,
                        color: CashlyColors.primaryLight,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: p.expense,
                        color: CashlyColors.accent,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: CashlyColors.mutedForeground)),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Dashboard data) {
    if (data.categoryBreakdown.isEmpty) return const SizedBox.shrink();
    final total = data.categoryBreakdown
        .fold<double>(0, (sum, c) => sum + c.total);

    return CashlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Gastos por categoria', subtitle: 'Distribuição atual'),
          const SizedBox(height: 16),
          ...data.categoryBreakdown.take(5).map((c) {
            final pct = total > 0 ? (c.total / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c.icon ?? '📊',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(c.categoryName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: CashlyColors.foreground)),
                      ),
                      Text(CashlyFormat.brl(c.total),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CashlyColors.foreground)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CashlyProgress(
                    value: pct.toDouble(),
                    color: c.color != null
                        ? _parseColor(c.color!)
                        : CashlyColors.primaryLight,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return CashlyColors.primaryLight;
    }
  }

  Widget _buildRecentTransactions(BuildContext context, Dashboard data) {
    if (data.recentTransactions.isEmpty) return const SizedBox.shrink();
    return CashlyCard(
      child: Column(
        children: [
          SectionHeader(
            title: 'Últimas transações',
            subtitle: 'As mais recentes',
            action: TextButton(
              onPressed: () => context.go('/transacoes'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todas',
                      style: TextStyle(
                          color: CashlyColors.primaryLight, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      color: CashlyColors.primaryLight, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...data.recentTransactions
              .take(5)
              .map((t) => TransactionListItem(transaction: t)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 70),
          const CashlyShimmer(height: 150, borderRadius: 20),
          const SizedBox(height: 12),
          Row(children: const [
            Expanded(child: CashlyShimmer(height: 90)),
            SizedBox(width: 12),
            Expanded(child: CashlyShimmer(height: 90)),
          ]),
          const SizedBox(height: 20),
          const CashlyShimmer(height: 200, borderRadius: 20),
          const SizedBox(height: 20),
          const CashlyShimmer(height: 260, borderRadius: 20),
        ],
      ),
    );
  }
}
