import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Redesign Container with border radius 18px and premium soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F1F33),
            blurRadius: 32,
            offset: Offset(0, 12),
            spreadRadius: -16,
          ),
        ],
      ),
      child: child,
    );
  }
}
