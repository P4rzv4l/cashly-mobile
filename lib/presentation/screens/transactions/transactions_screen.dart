import 'package:cashly/presentation/widgets/common/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/data/services/data_providers.dart';
import 'package:cashly/presentation/widgets/common/widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedType = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _updateFilters() {
    ref.read(transactionFiltersProvider.notifier).state = TransactionFilters(
      type: _selectedType == 'all' ? null : _selectedType,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: RefreshIndicator(
                color: CashlyColors.primaryLight,
                backgroundColor: CashlyColors.surface,
                onRefresh: () async => ref.invalidate(transactionsProvider),
                child: txAsync.when(
                  loading: () => _buildLoading(),
                  error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(transactionFiltersProvider),
                ),
                  data: (items) => items.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: CashlyColors.border,
                            height: 0.8,
                            indent: 54,
                          ),
                          itemBuilder: (_, i) =>
                              TransactionListItem(transaction: items[i]),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transações',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CashlyColors.foreground,
                  letterSpacing: -0.3)),
          SizedBox(height: 2),
          Text('Acompanhe e organize suas movimentações',
              style:
                  TextStyle(fontSize: 13, color: CashlyColors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => _updateFilters(),
            style: const TextStyle(color: CashlyColors.foreground),
            decoration: InputDecoration(
              hintText: 'Buscar...',
              hintStyle:
                  const TextStyle(color: CashlyColors.mutedForeground),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: CashlyColors.mutedForeground, size: 20),
              filled: true,
              fillColor: CashlyColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: CashlyColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: CashlyColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: CashlyColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _typeChip('all', 'Todos'),
                _typeChip('income', '↑ Entradas'),
                _typeChip('expense', '↓ Saídas'),
                _typeChip('transfer', '↔ Transferências'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final selected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = value);
          _updateFilters();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected ? CashlyColors.gradientPrimary : null,
            color: selected ? null : CashlyColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : CashlyColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : CashlyColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(
          8,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CashlyShimmer(height: 64, borderRadius: 12),
              )),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CashlyColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.swap_horiz_rounded,
                color: CashlyColors.mutedForeground, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Nenhuma transação encontrada',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CashlyColors.foreground)),
          const SizedBox(height: 6),
          const Text('Tente ajustar os filtros',
              style: TextStyle(
                  fontSize: 13, color: CashlyColors.mutedForeground)),
        ],
      ),
    );
  }
}
