import 'package:flutter/material.dart';

class GhSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData icon;
  final String? shortcutHint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const GhSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.icon = Icons.search,
    this.shortcutHint,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: shortcutHint == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  widthFactor: 1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colors.outline.withOpacity(0.4)),
                    ),
                    child: Text(shortcutHint!,
                        style:
                            TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  ),
                ),
              ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}