import 'package:flutter/material.dart';

typedef Validator<T> = String? Function(T? value);

class UserInputSelector<T> extends StatelessWidget {
  const UserInputSelector({
    super.key,
    this.value,
    required this.options,
    required this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.borderRadius = 10.0,
    this.style,
    this.dropdownColor,
    this.dropdownMaxHeight = 250,
    this.itemToString, // 👈 agregado
  });

  final T? value;
  final List<T> options;
  final String label;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final Validator<T>? validator;
  final double borderRadius;
  final TextStyle? style;
  final Color? dropdownColor;
  final double dropdownMaxHeight;
  final String Function(T)? itemToString; // 👈 agregado

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = style ?? theme.textTheme.bodyMedium;

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
      style: effectiveTextStyle,
      dropdownColor: dropdownColor ?? theme.canvasColor,
      menuMaxHeight: dropdownMaxHeight,
      icon: const SizedBox.shrink(),
      items: options.map((opt) {
        return DropdownMenuItem<T>(
          value: opt,
          child: Text(
            itemToString?.call(opt) ?? opt.toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
