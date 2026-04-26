import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashly/core/api/api_client.dart';
import 'package:cashly/core/constants/api_constants.dart';
import 'package:cashly/data/models/models.dart';

// ===== Dashboard =====
final dashboardProvider = FutureProvider<Dashboard>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.dashboard);
  return Dashboard.fromJson(res.data['data'] as Map<String, dynamic>);
});

// ===== Transactions =====
class TransactionFilters {
  final String? type;
  final String? accountId;
  final String? categoryId;
  final String? creditCardId;
  final String? status;
  final String? search;
  final int perPage;
  final int page;

  const TransactionFilters({
    this.type,
    this.accountId,
    this.categoryId,
    this.creditCardId,
    this.status,
    this.search,
    this.perPage = 50,
    this.page = 1,
  });

  Map<String, dynamic> toParams() => {
        if (type != null) 'type': type,
        if (accountId != null) 'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (creditCardId != null) 'credit_card_id': creditCardId,
        if (status != null) 'status': status,
        if (search != null && search!.isNotEmpty) 'search': search,
        'per_page': perPage,
        'page': page,
      };
}

final transactionFiltersProvider =
    StateProvider<TransactionFilters>((_) => const TransactionFilters());

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final filters = ref.watch(transactionFiltersProvider);
  final res = await ApiClient.instance.get(
    ApiConstants.transactions,
    params: filters.toParams(),
  );
  final paginatedData = res.data['data'] as Map<String, dynamic>;
  final items = paginatedData['data'] as List;
  return items.cast<Map<String, dynamic>>().map(Transaction.fromJson).toList();
});

// ===== Categories =====
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.categories);
  return (res.data['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(Category.fromJson)
      .toList();
});

// ===== Credit Cards =====
final creditCardsProvider = FutureProvider<List<CreditCard>>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.creditCards);
  return (res.data['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(CreditCard.fromJson)
      .toList();
});

// ===== Goals =====
final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.goals);
  return (res.data['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(Goal.fromJson)
      .toList();
});

// ===== Reserves =====
final reservesProvider = FutureProvider<List<Reserve>>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.reserves);
  return (res.data['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(Reserve.fromJson)
      .toList();
});

// ===== Accounts =====
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final res = await ApiClient.instance.get(ApiConstants.accounts);
  return (res.data['data'] as List)
      .cast<Map<String, dynamic>>()
      .map(Account.fromJson)
      .toList();
});
