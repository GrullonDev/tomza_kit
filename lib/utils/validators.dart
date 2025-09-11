class Validators {
  static String? notEmpty(String? value, {String message = 'Campo requerido'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static bool isEmail(String value) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
}
