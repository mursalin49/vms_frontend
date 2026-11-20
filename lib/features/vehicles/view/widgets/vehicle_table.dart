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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 52,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                horizontalMargin: 28,
                columnSpacing: 28,
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
                        // Vehicle Number (Bold navy)
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
                        // Status pill
                        DataCell(StatusBadge(v.status)),
                        // Actions
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
          );
        },
      ),
    );
  }
}
