import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height = 46,
    this.borderRadius = 10,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: disabled
            ? const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
            : const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E60FF)],
              ),
        boxShadow: disabled
            ? null
            : const [
                BoxShadow(
                  color: Color(0x4D1E60FF),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                  spreadRadius: -2,
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
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
