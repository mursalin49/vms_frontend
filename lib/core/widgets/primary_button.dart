import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height = 46,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 17, color: AppColors.white), const SizedBox(width: 8)],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          );

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: disabled
            ? const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.corporateBlue, AppColors.deepBlue],
              ),
        boxShadow: disabled
            ? null
            : const [
                BoxShadow(
                  color: Color(0x661F4E79),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  spreadRadius: -4,
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget;
  }
}
