import 'package:intl/intl.dart';

class Formatters {
  static String currency(num value, {String locale = 'es_GT'}) {
    return NumberFormat.simpleCurrency(locale: locale).format(value);
  }
}
