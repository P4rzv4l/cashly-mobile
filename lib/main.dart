import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cashly/core/router.dart';
import 'package:cashly/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CashlyColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Init Brazilian date locale
  await initializeDateFormatting('pt_BR', null);

  runApp(const ProviderScope(child: CashlyApp()));
}

class CashlyApp extends ConsumerWidget {
  const CashlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Cashly',
      debugShowCheckedModeBanner: false,
      theme: CashlyTheme.dark,
      routerConfig: router,
    );
  }
}
