import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/vehicle.dart';
import '../../domain/vehicle_status.dart';

class VehicleStatsCards extends StatelessWidget {
  const VehicleStatsCards({super.key, required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    final total = vehicles.length;
    final active = vehicles.where((v) => v.status == VehicleStatus.active).length;
    final maintenance = vehicles.where((v) => v.status == VehicleStatus.maintenance).length;
    final inactive = vehicles.where((v) => v.status == VehicleStatus.inactive).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isDesktop = w >= 860;
        const gap = 12.0;

        // 4 columns on desktop, 2 columns on mobile/tablet
        final cardWidth = isDesktop ? (w - (3 * gap)) / 4 : (w - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Total vehicles',
                count: total,
                ratio: 1.0,
                barColor: AppColors.deepBlue,
                isSmall: !isDesktop,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Active',
                count: active,
                ratio: total > 0 ? active / total : 0,
                barColor: AppColors.green,
                isSmall: !isDesktop,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Maintenance',
                count: maintenance,
                ratio: total > 0 ? maintenance / total : 0,
                barColor: AppColors.maintenanceBar,
                isSmall: !isDesktop,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Inactive',
                count: inactive,
                ratio: total > 0 ? inactive / total : 0,
                barColor: AppColors.inactiveBar,
                isSmall: !isDesktop,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.ratio,
    required this.barColor,
    this.isSmall = false,
  });

  final String label;
  final int count;
  final double ratio;
  final Color barColor;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 20,
        vertical: isSmall ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmall ? 4 : 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: isSmall ? 26 : 34,
              fontWeight: FontWeight.w800,
              color: AppColors.brandNavy,
              height: 1.1,
            ),
          ),
          SizedBox(height: isSmall ? 10 : 14),
          // Progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 5,
              width: double.infinity,
              color: AppColors.grayBg,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(color: barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
