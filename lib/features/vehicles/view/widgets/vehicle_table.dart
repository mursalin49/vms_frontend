import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/vehicle.dart';

class VehicleTable extends StatelessWidget {
  const VehicleTable({
    super.key,
    required this.vehicles,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle> onEdit;
  final ValueChanged<Vehicle> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        if (isMobile) {
          return _buildMobileCardList();
        }

        return _buildDesktopTable(constraints.maxWidth);
      },
    );
  }

  /// Mobile-optimized card list (< 680px)
  Widget _buildMobileCardList() {
    return Column(
      children: [
        for (final v in vehicles)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0F1F33),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Plate number & Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      v.vehicleNumber,
                      style: const TextStyle(
                        color: AppColors.brandNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.4,
                      ),
                    ),
                    StatusBadge(v.status),
                  ],
                ),
                const SizedBox(height: 10),

                // Vehicle make & model
                Text(
                  '${v.brand} ${v.model}',
                  style: const TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),

                // Type & Company
                Text(
                  '${v.type} · ${v.company}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.tableBorder),
                const SizedBox(height: 6),

                // Bottom row: Edit & Delete buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.deepBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => onEdit(v),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => onDelete(v),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Desktop / Tablet DataTable (>= 680px)
  Widget _buildDesktopTable(double maxWidth) {
    final isCompact = maxWidth < 880;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F1F33),
            blurRadius: 32,
            offset: Offset(0, 12),
            spreadRadius: -16,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxWidth),
          child: DataTable(
            headingRowHeight: 52,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            horizontalMargin: 24,
            columnSpacing: 24,
            headingRowColor: WidgetStateProperty.all(AppColors.tableHeader),
            dividerThickness: 1,
            border: const TableBorder(
              horizontalInside: BorderSide(color: AppColors.tableBorder, width: 1),
            ),
            headingTextStyle: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
            ),
            columns: [
              const DataColumn(label: Text('VEHICLE NO.')),
              if (!isCompact) const DataColumn(label: Text('COMPANY')),
              const DataColumn(label: Text('TYPE')),
              if (!isCompact) const DataColumn(label: Text('BRAND')),
              if (!isCompact) const DataColumn(label: Text('MODEL')),
              const DataColumn(label: Text('STATUS')),
              const DataColumn(label: Text('ACTIONS')),
            ],
            rows: [
              for (final v in vehicles)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        v.vehicleNumber,
                        style: const TextStyle(
                          color: AppColors.brandNavy,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (!isCompact)
                      DataCell(
                        Text(
                          v.company,
                          style: const TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    DataCell(
                      Text(
                        v.type,
                        style: const TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!isCompact)
                      DataCell(
                        Text(
                          v.brand,
                          style: const TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (!isCompact)
                      DataCell(
                        Text(
                          v.model,
                          style: const TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    DataCell(StatusBadge(v.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.deepBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () => onEdit(v),
                            child: const Text('Edit'),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () => onDelete(v),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
