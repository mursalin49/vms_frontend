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
        final isWide = constraints.maxWidth >= 840;
        final cardWidth = isWide ? (constraints.maxWidth - (3 * 16)) / 4 : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Total vehicles',
                count: total,
                ratio: 1.0,
                barColor: AppColors.deepBlue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Active',
                count: active,
                ratio: total > 0 ? active / total : 0,
                barColor: AppColors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Maintenance',
                count: maintenance,
                ratio: total > 0 ? maintenance / total : 0,
                barColor: AppColors.maintenanceBar,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Inactive',
                count: inactive,
                ratio: total > 0 ? inactive / total : 0,
                barColor: AppColors.inactiveBar,
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
  });

  final String label;
  final int count;
  final double ratio;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.brandNavy,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          // Progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 6,
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

