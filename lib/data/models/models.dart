// Helper: parse num or string to double safely
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

// ===== User =====
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? currency;
  final String? locale;
  final String? timezone;
  final double? monthlyIncome;
  final bool? isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.currency,
    this.locale,
    this.timezone,
    this.monthlyIncome,
    this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        phone: j['phone']?.toString(),
        avatar: j['avatar']?.toString(),
        currency: j['currency']?.toString(),
        locale: j['locale']?.toString(),
        timezone: j['timezone']?.toString(),
        monthlyIncome: (j['monthly_income'] as num?)?.toDouble(),
        isActive: j['is_active'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'email': email, 'phone': phone,
        'avatar': avatar, 'currency': currency, 'locale': locale,
        'timezone': timezone, 'monthly_income': monthlyIncome, 'is_active': isActive,
      };

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  String get firstName => name.split(' ').first;
}

// ===== Account =====
class Account {
  final String id;
  final String name;
  final String type;
  final String? bankName;
  final String? color;
  final String? icon;
  final double balance;
  final String currency;
  final bool includeInTotal;

  const Account({
    required this.id, required this.name, required this.type,
    this.bankName, this.color, this.icon,
    required this.balance, required this.currency, required this.includeInTotal,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        bankName: j['bank_name']?.toString(),
        color: j['color']?.toString(),
        icon: j['icon']?.toString(),
        balance: _toDouble(j['balance']) ?? 0,
        currency: j['currency']?.toString() ?? 'BRL',
        includeInTotal: j['include_in_total'] as bool? ?? true,
      );
}

// ===== Category =====
class Category {
  final String id;
  final String name;
  final String type;
  final String? color;
  final String? icon;
  final String? parentId;

  const Category({
    required this.id, required this.name, required this.type,
    this.color, this.icon, this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        color: j['color']?.toString(),
        icon: j['icon']?.toString(),
        parentId: j['parent_id']?.toString(),
      );
}

// ===== Transaction =====
class TransactionRef {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  const TransactionRef({required this.id, required this.name, this.icon, this.color});

  factory TransactionRef.fromJson(Map<String, dynamic> j) => TransactionRef(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        icon: j['icon']?.toString(),
        color: j['color']?.toString(),
      );
}

class Transaction {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String date;
  final String status;
  final String? paymentMethod;
  final bool? isInstallment;
  final int? installmentCount;
  final String? notes;
  final List<String>? tags;
  final TransactionRef? account;
  final TransactionRef? category;
  final TransactionRef? creditCard;

  const Transaction({
    required this.id, required this.type, required this.description,
    required this.amount, required this.date, required this.status,
    this.paymentMethod, this.isInstallment, this.installmentCount,
    this.notes, this.tags, this.account, this.category, this.creditCard,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        amount: _toDouble(j['amount']) ?? 0,
        date: j['date']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        paymentMethod: j['payment_method']?.toString(),
        isInstallment: j['is_installment'] as bool?,
        installmentCount: j['installment_count'] as int?,
        notes: j['notes']?.toString(),
        tags: (j['tags'] as List?)?.map((e) => e.toString()).toList(),
        account: j['account'] != null
            ? TransactionRef.fromJson(j['account'] as Map<String, dynamic>) : null,
        category: j['category'] != null
            ? TransactionRef.fromJson(j['category'] as Map<String, dynamic>) : null,
        creditCard: j['credit_card'] != null
            ? TransactionRef.fromJson(j['credit_card'] as Map<String, dynamic>) : null,
      );

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isTransfer => type == 'transfer';
}

// ===== Credit Card =====
class CreditCard {
  final String id;
  final String name;
  final String brand;
  final String? lastFourDigits;
  final String? color;
  final double creditLimit;
  final double usedLimit;
  final double availableLimit;
  final int closingDay;
  final int dueDay;
  final bool? isInternational;

  const CreditCard({
    required this.id, required this.name, required this.brand,
    this.lastFourDigits, this.color,
    required this.creditLimit, required this.usedLimit, required this.availableLimit,
    required this.closingDay, required this.dueDay, this.isInternational,
  });

  factory CreditCard.fromJson(Map<String, dynamic> j) => CreditCard(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        brand: j['brand']?.toString() ?? '',
        lastFourDigits: j['last_four_digits']?.toString(),
        color: j['color']?.toString(),
        creditLimit: (j['credit_limit'] as num?)?.toDouble() ?? 0,
        usedLimit: (j['used_limit'] as num?)?.toDouble() ?? 0,
        availableLimit: (j['available_limit'] as num?)?.toDouble() ?? 0,
        closingDay: (j['closing_day'] as num?)?.toInt() ?? 1,
        dueDay: (j['due_day'] as num?)?.toInt() ?? 1,
        isInternational: j['is_international'] as bool?,
      );

  double get usagePercent =>
      creditLimit > 0 ? (usedLimit / creditLimit * 100).clamp(0, 100) : 0;
}

// ===== Goal =====
class Goal {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final double targetAmount;
  final double currentAmount;
  final double remainingAmount;
  final double progressPercentage;
  final double? monthlyContribution;
  final String? targetDate;
  final String status;
  final int? priority;

  const Goal({
    required this.id, required this.name, this.description, this.icon, this.color,
    required this.targetAmount, required this.currentAmount,
    required this.remainingAmount, required this.progressPercentage,
    this.monthlyContribution, this.targetDate, required this.status, this.priority,
  });

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString(),
        icon: j['icon']?.toString(),
        color: j['color']?.toString(),
        targetAmount: (j['target_amount'] as num?)?.toDouble() ?? 0,
        currentAmount: (j['current_amount'] as num?)?.toDouble() ?? 0,
        remainingAmount: (j['remaining_amount'] as num?)?.toDouble() ?? 0,
        progressPercentage: (j['progress_percentage'] as num?)?.toDouble() ?? 0,
        monthlyContribution: (j['monthly_contribution'] as num?)?.toDouble(),
        targetDate: j['target_date']?.toString(),
        status: j['status']?.toString() ?? 'active',
        priority: (j['priority'] as num?)?.toInt(),
      );

  bool get isCompleted => status == 'completed' || currentAmount >= targetAmount;
}

// ===== Reserve =====
class Reserve {
  final String id;
  final String name;
  final String? type;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final int? targetMonths;

  const Reserve({
    required this.id, required this.name, this.type, this.description,
    required this.targetAmount, required this.currentAmount, this.targetMonths,
  });

  factory Reserve.fromJson(Map<String, dynamic> j) => Reserve(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        type: j['type']?.toString(),
        description: j['description']?.toString(),
        targetAmount: (j['target_amount'] as num?)?.toDouble() ?? 0,
        currentAmount: (j['current_amount'] as num?)?.toDouble() ?? 0,
        targetMonths: (j['target_months'] as num?)?.toInt(),
      );

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;
}

// ===== Dashboard =====
class DashboardBalance {
  final double totalBalance;
  final double committedBalance;
  final double availableBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyBalance;

  const DashboardBalance({
    required this.totalBalance, required this.committedBalance,
    required this.availableBalance, required this.monthlyIncome,
    required this.monthlyExpense, required this.monthlyBalance,
  });

  factory DashboardBalance.fromJson(Map<String, dynamic> j) => DashboardBalance(
        totalBalance: (j['total_balance'] as num?)?.toDouble() ?? 0,
        committedBalance: (j['committed_balance'] as num?)?.toDouble() ?? 0,
        availableBalance: (j['available_balance'] as num?)?.toDouble() ?? 0,
        monthlyIncome: (j['monthly_income'] as num?)?.toDouble() ?? 0,
        monthlyExpense: (j['monthly_expense'] as num?)?.toDouble() ?? 0,
        monthlyBalance: (j['monthly_balance'] as num?)?.toDouble() ?? 0,
      );
}

class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String? color;
  final String? icon;
  final double total;

  const CategoryBreakdown({
    required this.categoryId, required this.categoryName,
    this.color, this.icon, required this.total,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> j) => CategoryBreakdown(
        categoryId: j['category_id']?.toString() ?? '',
        categoryName: j['category_name']?.toString() ?? '',
        color: j['color']?.toString(),
        icon: j['icon']?.toString(),
        total: (j['total'] as num?)?.toDouble() ?? 0,
      );
}

class MonthlyChartPoint {
  final String label;
  final double income;
  final double expense;

  const MonthlyChartPoint({required this.label, required this.income, required this.expense});

  factory MonthlyChartPoint.fromJson(Map<String, dynamic> j) => MonthlyChartPoint(
        label: j['label']?.toString() ?? '',
        income: (j['income'] as num?)?.toDouble() ?? 0,
        expense: (j['expense'] as num?)?.toDouble() ?? 0,
      );
}

class EndOfMonthForecast {
  final double currentBalance;
  final double remainingIncome;
  final double remainingExpenses;
  final double pendingInstallments;
  final double projectedEomBalance;
  final int daysRemaining;

  const EndOfMonthForecast({
    required this.currentBalance, required this.remainingIncome,
    required this.remainingExpenses, required this.pendingInstallments,
    required this.projectedEomBalance, required this.daysRemaining,
  });

  factory EndOfMonthForecast.fromJson(Map<String, dynamic> j) => EndOfMonthForecast(
        currentBalance: (j['current_balance'] as num?)?.toDouble() ?? 0,
        remainingIncome: (j['remaining_income'] as num?)?.toDouble() ?? 0,
        remainingExpenses: (j['remaining_expenses'] as num?)?.toDouble() ?? 0,
        pendingInstallments: (j['pending_installments'] as num?)?.toDouble() ?? 0,
        projectedEomBalance: (j['projected_eom_balance'] as num?)?.toDouble() ?? 0,
        daysRemaining: j['days_remaining'] != null ? (j['days_remaining'] as num).toInt() : 0,
      );
}

class FinancialHealth {
  final double score;
  final String status;
  final List<Map<String, dynamic>>? recommendations;

  const FinancialHealth({required this.score, required this.status, this.recommendations});

  factory FinancialHealth.fromJson(Map<String, dynamic> j) => FinancialHealth(
        score: (j['score'] as num?)?.toDouble() ?? 0,
        status: j['status']?.toString() ?? '',
        recommendations: (j['recommendations'] as List?)?.cast<Map<String, dynamic>>(),
      );
}

class Dashboard {
  final DashboardBalance balance;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<MonthlyChartPoint> monthlyChart;
  final EndOfMonthForecast? endOfMonthForecast;
  final FinancialHealth? financialHealth;
  final List<Transaction> recentTransactions;

  const Dashboard({
    required this.balance,
    required this.categoryBreakdown,
    required this.monthlyChart,
    this.endOfMonthForecast,
    this.financialHealth,
    required this.recentTransactions,
  });

  factory Dashboard.fromJson(Map<String, dynamic> j) {
    try {
      return Dashboard(
        balance: DashboardBalance.fromJson(
            (j['balance'] as Map<String, dynamic>?) ?? {}),
        categoryBreakdown: ((j['category_breakdown'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(CategoryBreakdown.fromJson)
            .toList(),
        monthlyChart: ((j['monthly_chart'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(MonthlyChartPoint.fromJson)
            .toList(),
        endOfMonthForecast: j['end_of_month_forecast'] != null
            ? EndOfMonthForecast.fromJson(
                j['end_of_month_forecast'] as Map<String, dynamic>)
            : null,
        financialHealth: j['financial_health'] != null
            ? FinancialHealth.fromJson(
                j['financial_health'] as Map<String, dynamic>)
            : null,
        recentTransactions: ((j['recent_transactions'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(Transaction.fromJson)
            .toList(),
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Dashboard.fromJson error: $e\n$st');
      rethrow;
    }
  }
}

// ===== AI =====
class AiReply {
  final String interactionId;
  final String message;
  final String sessionId;
  final int? tokensUsed;

  const AiReply({
    required this.interactionId, required this.message,
    required this.sessionId, this.tokensUsed,
  });

  factory AiReply.fromJson(Map<String, dynamic> j) => AiReply(
        interactionId: j['interaction_id']?.toString() ?? '',
        message: j['message']?.toString() ?? '',
        sessionId: j['session_id']?.toString() ?? '',
        tokensUsed: j['tokens_used'] as int?,
      );
}
