import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/utils/format.dart';

// ===== GradientButton =====
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? CashlyColors.gradientPrimary
              : const LinearGradient(colors: [Color(0xFF4B3A7A), Color(0xFF6B3A7A)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed != null
              ? [BoxShadow(color: CashlyColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : child,
        ),
      ),
    );
  }
}

// ===== CashlyCard =====
class CashlyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CashlyCard({super.key, required this.child, this.padding, this.backgroundColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? CashlyColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CashlyColors.border, width: 0.8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

// ===== GradientCard =====
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CashlyColors.gradientCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: CashlyColors.primary.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

// ===== StatCard =====
class StatCard extends StatelessWidget {
  final String label;
  final double value;
  final bool gradient;
  final bool hidden;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.gradient = false,
    this.hidden = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ? CashlyColors.gradientCard : null,
        color: gradient ? null : CashlyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: gradient ? null : Border.all(color: CashlyColors.border, width: 0.8),
        boxShadow: [
          if (gradient)
            BoxShadow(color: CashlyColors.primary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8))
          else
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient ? Colors.white.withOpacity(0.2) : CashlyColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: gradient ? Colors.white : CashlyColors.primaryLight),
            ),
          ]),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, color: gradient ? Colors.white.withOpacity(0.8) : CashlyColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(
            hidden ? 'R\$ •••••' : CashlyFormat.brl(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: gradient ? Colors.white : CashlyColors.foreground,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Loading Shimmer =====
class CashlyShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const CashlyShimmer({super.key, required this.height, this.width, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CashlyColors.surface,
      highlightColor: CashlyColors.surfaceElevated,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: CashlyColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ===== Section Header =====
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: CashlyColors.foreground)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: CashlyColors.mutedForeground)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ===== Progress Bar =====
class CashlyProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;

  const CashlyProgress({super.key, required this.value, this.height = 6, this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: (value / 100).clamp(0.0, 1.0),
        backgroundColor: CashlyColors.border,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? CashlyColors.primary),
        minHeight: height,
      ),
    );
  }
}

// ===== Transaction Item =====
class TransactionListItem extends StatelessWidget {
  final dynamic transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final isTransfer = transaction.type == 'transfer';
    final color = isIncome
        ? CashlyColors.success
        : isTransfer
            ? CashlyColors.primaryLight
            : CashlyColors.danger;
    final sign = isIncome ? '+' : isTransfer ? '' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.category?.icon ?? (isIncome ? '💰' : isTransfer ? '↔️' : '💸'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CashlyColors.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.category?.name ?? CashlyFormat.date(transaction.date),
                  style: const TextStyle(fontSize: 11, color: CashlyColors.mutedForeground),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${CashlyFormat.brl(transaction.amount)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
              ),
              Text(
                CashlyFormat.date(transaction.date),
                style: const TextStyle(fontSize: 10, color: CashlyColors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== Cashly Input Field =====
class CashlyTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final bool enabled;

  const CashlyTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: CashlyColors.foreground)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(color: CashlyColors.foreground),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}
