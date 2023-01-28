import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double amount) {
    NumberFormat format = NumberFormat.simpleCurrency(
      locale: 'vi',
      decimalDigits: 0,
    );

    return format.format(amount);
  }
}

class NumberHelper {
  static String format(double amount) {
    NumberFormat format = NumberFormat.decimalPattern();

    return format.format(amount);
  }
}
