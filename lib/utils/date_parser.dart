import 'package:intl/intl.dart';

class DateParser {
  static DateTime? stringToDateTime(
    String dateStr, {
    String format = 'dd/MM/yyyy',
  }) {
    try {
      return DateFormat(format).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static String dateTimeToString(
    DateTime date, {
    String format = 'dd/MM/yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  static String? convertFormat(
    String dateStr, {
    required String inputFormat,
    required String outputFormat,
  }) {
    try {
      final date = DateFormat(inputFormat).parse(dateStr);
      return DateFormat(outputFormat).format(date);
    } catch (e) {
      return null;
    }
  }

  /// Convierte una fecha del formato DD/MM/AAAA a MM/DD/AAAA
  static String? ddMmYyyyToMmDdYyyy(String dateStr) {
    return convertFormat(
      dateStr,
      inputFormat: 'dd/MM/yyyy',
      outputFormat: 'MM/dd/yyyy',
    );
  }

  /// Convierte una fecha del formato MM/DD/AAAA a DD/MM/AAAA
  static String? mmDdYyyyToDdMmYyyy(String dateStr) {
    return convertFormat(
      dateStr,
      inputFormat: 'MM/dd/yyyy',
      outputFormat: 'dd/MM/yyyy',
    );
  }

  /// Convierte una fecha del formato AAAA/DD/MM a DD/MM/AAAA
  static String? yyyyDdMmToDdMmYyyy(String dateStr) {
    return convertFormat(
      dateStr,
      inputFormat: 'yyyy/dd/MM',
      outputFormat: 'dd/MM/yyyy',
    );
  }

  /// Convierte una fecha del formato DD/MM/AAAA a AAAA/DD/MM
  static String? ddMmYyyyToYyyyDdMm(String dateStr) {
    return convertFormat(
      dateStr,
      inputFormat: 'dd/MM/yyyy',
      outputFormat: 'yyyy/dd/MM',
    );
  }

  static bool isValidDate(String dateStr, {String format = 'dd/MM/yyyy'}) {
    try {
      final date = DateFormat(format).parseStrict(dateStr);
      return date != null;
    } catch (e) {
      return false;
    }
  }

  static String getCurrentDate({String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(DateTime.now());
  }
}
