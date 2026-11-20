import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Delete confirmation. Red is reserved for delete actions and errors.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title,
          style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
      content: SizedBox(width: 380, child: Text(message)),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
