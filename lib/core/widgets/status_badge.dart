import 'package:flutter/material.dart';

import '../../features/vehicles/domain/vehicle_status.dart';
import '../theme/app_colors.dart';

/// Status Pill matching the new redesign:
/// Active = #E8F8F0 / #10B981
/// Maintenance = #FFF7E6 / #F59E0B
/// Inactive = #F1F5F9 / #64748B
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.isDark = false});

  final VehicleStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;

    if (isDark) {
      switch (status) {
        case VehicleStatus.active:
          bg = const Color(0x2E34D399);
          fg = const Color(0xFF6EE7B7);
        case VehicleStatus.maintenance:
          bg = const Color(0x2EFBBF24);
          fg = const Color(0xFFFCD34D);
        case VehicleStatus.inactive:
          bg = const Color(0x2E94A3B8);
          fg = const Color(0xFFCBD5E1);
      }
    } else {
      switch (status) {
        case VehicleStatus.active:
          bg = AppColors.greenBg;
          fg = AppColors.green;
        case VehicleStatus.maintenance:
          bg = AppColors.maintenanceBg;
          fg = AppColors.maintenance;
        case VehicleStatus.inactive:
          bg = AppColors.grayBg;
          fg = AppColors.inactive;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
