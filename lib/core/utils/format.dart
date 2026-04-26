import 'package:intl/intl.dart';

class CashlyFormat {
  static final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _compact = NumberFormat.compactCurrency(
    locale: 'pt_BR', symbol: 'R\$', decimalDigits: 1,
  );
  static final _percent = NumberFormat('##0.0', 'pt_BR');
  static final _dateShort = DateFormat("dd MMM", 'pt_BR');
  static final _dateLong = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
  static final _time = DateFormat('HH:mm', 'pt_BR');

  static String brl(num value) => _brl.format(value);

  static String compactBrl(num value) => _compact.format(value);

  static String percent(num value, {int digits = 1}) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(digits)}%';
  }

  static String date(String iso) {
    try {
      return _dateShort.format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  static String longDate(String iso) {
    try {
      return _dateLong.format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  static String time(DateTime dt) => _time.format(dt);

  static String timeFromIso(String iso) {
    try {
      return _time.format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}
