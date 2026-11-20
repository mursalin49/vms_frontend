import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Placeholder rows shown while data loads.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w) => Container(
          width: w,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.grayBg,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    return Semantics(
      label: 'Loading vehicles',
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(children: [
                bar(140),
                const SizedBox(width: 24),
                bar(120),
                const SizedBox(width: 24),
                bar(80),
                const SizedBox(width: 24),
                bar(100),
                const SizedBox(width: 24),
                bar(90),
              ]),
            ),
        ],
      ),
    );
  }
}
