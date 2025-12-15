import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TomzaSearchField<T> extends StatelessWidget {
  const TomzaSearchField({
    super.key,
    required this.items,
    required this.itemToString,
    required this.onItemSelected,
    required this.controller,
    this.hintText = 'Buscar...',
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
    this.onClear,
    this.validator,
    this.onChanged,
    this.color,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  });

  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T) onItemSelected;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onClear;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (prefixIcon ?? const Icon(Icons.search)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: enabled
                    ? () {
                        controller.clear();
                        if (onClear != null) onClear!();
                      }
                    : null,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.zenAntiqueSoft(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
