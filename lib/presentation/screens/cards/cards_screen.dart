import 'package:cashly/presentation/widgets/common/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';
import 'package:cashly/data/models/models.dart';
import 'package:cashly/data/services/data_providers.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardsProvider);

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
                  Text('Cartões',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: CashlyColors.foreground,
                          letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Limites e uso de cada cartão',
                      style: TextStyle(
                          fontSize: 13, color: CashlyColors.mutedForeground)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: CashlyColors.primaryLight,
                backgroundColor: CashlyColors.surface,
                onRefresh: () async => ref.invalidate(creditCardsProvider),
                child: cardsAsync.when(
                  loading: () => _buildLoading(),
                  error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(creditCardsProvider),
                ),
                  data: (cards) => cards.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          itemCount: cards.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) => _CardItem(card: cards[i]),
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
          3,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CashlyShimmer(height: 220, borderRadius: 20),
              )),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_off_rounded,
              color: CashlyColors.mutedForeground, size: 48),
          SizedBox(height: 12),
          Text('Nenhum cartão encontrado',
              style: TextStyle(color: CashlyColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final CreditCard card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    final pct = card.usagePercent;
    final barColor = pct > 80
        ? CashlyColors.danger
        : pct > 50
            ? CashlyColors.warning
            : CashlyColors.primaryLight;

    return CashlyCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCardVisual(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Uso do limite',
                        style: TextStyle(
                            fontSize: 12,
                            color: CashlyColors.mutedForeground)),
                    Text('${pct.toInt()}%',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CashlyColors.foreground)),
                  ],
                ),
                const SizedBox(height: 6),
                CashlyProgress(value: pct, color: barColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Usado ${CashlyFormat.brl(card.usedLimit)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: CashlyColors.mutedForeground)),
                    Text('Disponível ${CashlyFormat.brl(card.availableLimit)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: CashlyColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _infoTile('Limite total',
                          CashlyFormat.brl(card.creditLimit)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoTile('Bandeira',
                          card.brand.toUpperCase()),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoTile(
                          'Vencimento', 'Dia ${card.dueDay}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardVisual() {
    final cardColor = card.color != null
        ? _parseColor(card.color!)
        : null;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: cardColor != null
            ? LinearGradient(
                colors: [cardColor, cardColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : CashlyColors.gradientCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const Icon(Icons.credit_card_rounded,
                  color: Colors.white70, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.lastFourDigits != null
                    ? '•••• •••• •••• ${card.lastFourDigits}'
                    : '•••• •••• •••• ••••',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text(
                CashlyFormat.brl(card.creditLimit),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CashlyColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: CashlyColors.mutedForeground)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CashlyColors.foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return CashlyColors.primary;
    }
  }
}
