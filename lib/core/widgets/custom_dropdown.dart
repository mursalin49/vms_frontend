import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
    this.itemLabel,
  });

  final String label;
  final List<T> items;
  final T? value;
  final String? hint;
  final String? Function(T?)? validator;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          // ignore: deprecated_member_use
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSubtle),
                ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
          validator: validator,
          onChanged: onChanged,
          items: [
            for (final i in items)
              DropdownMenuItem<T>(
                value: i,
                child: Text(
                  itemLabel?.call(i) ?? '$i',
                  style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
                ),
              ),
          ],
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
