import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/api/api_client.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String? title;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isServer = error is DioException &&
        (error as DioException).response?.statusCode != null &&
        (error as DioException).response!.statusCode! >= 500;

    final isNetwork = error is DioException &&
        ((error as DioException).type == DioExceptionType.connectionError ||
            (error as DioException).type == DioExceptionType.connectionTimeout);

    final icon = isNetwork
        ? Icons.wifi_off_rounded
        : isServer
            ? Icons.cloud_off_rounded
            : Icons.error_outline_rounded;

    final color = isNetwork ? CashlyColors.warning : CashlyColors.danger;
    final message = ApiClient.errorMessage(error);
    final hint = isServer
        ? 'O servidor retornou um erro interno. Verifique os logs do backend.'
        : isNetwork
            ? 'Verifique sua conexão e se o servidor está rodando.'
            : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title ?? 'Algo deu errado',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CashlyColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: CashlyColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (hint != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: CashlyColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CashlyColors.border),
                ),
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CashlyColors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: CashlyColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  label: const Text('Tentar novamente',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
