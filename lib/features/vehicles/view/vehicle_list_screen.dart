import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import '../viewmodel/vehicle_list_viewmodel.dart';

class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  final _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  int _currentPage = 1;
  static const int _pageSize = 8;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Vehicle v) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete vehicle?',
      message: 'Vehicle ${v.vehicleNumber} will be permanently removed.',
    );
    if (!confirmed) return;
    try {
      await ref.read(vehicleListProvider.notifier).delete(v.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _showVehicleDetailsDialog(BuildContext context, Vehicle v) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.vehicleNumber,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.brandNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${v.brand} ${v.model}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            StatusBadge(v.status),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 24),
              _buildDetailRow('Company', v.company, Icons.business_rounded),
              const SizedBox(height: 12),
              _buildDetailRow('Vehicle Type', v.type, Icons.commute_rounded),
              const SizedBox(height: 12),
              _buildDetailRow('Brand', v.brand, Icons.sell_outlined),
              const SizedBox(height: 12),
              _buildDetailRow('Model', v.model, Icons.directions_car_outlined),
              const SizedBox(height: 12),
              _buildDetailRow('Status', v.status.label, Icons.check_circle_outline_rounded),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.charcoal,
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/vehicles/${v.id}/edit');
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListProvider);

    return vehiclesAsync.when(
      loading: () => const LoadingSkeleton(),
      error: (e, _) => EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load vehicles',
        message: e is AppException ? e.message : 'Something went wrong. Try again.',
        action: OutlinedButton(
          onPressed: () => ref.invalidate(vehicleListProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (allVehicles) {
        // Search & Filter
        final query = _searchController.text.trim().toLowerCase();
        final filteredList = allVehicles.where((v) {
          if (_statusFilter != null && v.status != _statusFilter) {
            return false;
          }
          if (query.isNotEmpty) {
            final matchesNumber = v.vehicleNumber.toLowerCase().contains(query);
            final matchesCompany = v.company.toLowerCase().contains(query);
            final matchesBrand = v.brand.toLowerCase().contains(query);
            final matchesModel = v.model.toLowerCase().contains(query);
            return matchesNumber || matchesCompany || matchesBrand || matchesModel;
          }
          return true;
        }).toList();

        final totalFiltered = filteredList.length;
        final totalPages = (totalFiltered / _pageSize).ceil().clamp(1, 999);
        final startIdx = ((_currentPage - 1) * _pageSize).clamp(0, totalFiltered);
        final endIdx = (startIdx + _pageSize).clamp(0, totalFiltered);
        final pageList = filteredList.sublist(startIdx, endIdx);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Banner
              _buildTopBanner(context),
              const SizedBox(height: 20),

              // 2. Vehicle List Table Card (Focused purely on Viewing and Actions)
              _buildVehicleListCard(
                context,
                allVehicles,
                pageList,
                totalFiltered,
                totalPages,
                startIdx,
                endIdx,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Top Banner matching Image 1
  Widget _buildTopBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE0EAFC),
            Color(0xFFCFDEF3),
            Color(0xFFE8F1FC),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          const bannerHeight = 125.0;
          final fleetWidth = isNarrow ? 320.0 : (constraints.maxWidth * 0.54).clamp(460.0, 600.0);

          return SizedBox(
            height: bannerHeight,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                if (!isNarrow)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: FleetBanner(
                      width: fleetWidth,
                      height: bannerHeight,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x331E60FF),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vehicle Management',
                              style: TextStyle(
                                color: AppColors.charcoal,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage and monitor your fleet with ease and efficiency.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) const SizedBox(width: 320),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Vehicle List Table Card matching Image 1
  Widget _buildVehicleListCard(
    BuildContext context,
    List<Vehicle> allVehicles,
    List<Vehicle> pageList,
    int totalFiltered,
    int totalPages,
    int startIdx,
    int endIdx,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Vehicle List title + Search, Filter & Register Vehicle Button
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 780;

              final titlePart = Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle List',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'All registered vehicles are shown below.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              );

              final controlsPart = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Input
                  Container(
                    width: isNarrow ? 200 : 240,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() => _currentPage = 1),
                      style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
                      decoration: const InputDecoration(
                        hintText: 'Search vehicles...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSubtle),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.muted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Filter Menu
                  PopupMenuButton<VehicleStatus?>(
                    initialValue: _statusFilter,
                    onSelected: (s) => setState(() {
                      _statusFilter = s;
                      _currentPage = 1;
                    }),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('All Statuses')),
                      const PopupMenuItem(value: VehicleStatus.active, child: Text('Active Only')),
                      const PopupMenuItem(value: VehicleStatus.maintenance, child: Text('Maintenance Only')),
                      const PopupMenuItem(value: VehicleStatus.inactive, child: Text('Inactive Only')),
                    ],
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.charcoal),
                          const SizedBox(width: 6),
                          Text(
                            _statusFilter == null ? 'Filter' : _statusFilter!.label,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // + Register Vehicle Primary Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go('/vehicles/new'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Register Vehicle',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titlePart,
                    const SizedBox(height: 14),
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: controlsPart),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titlePart,
                  controlsPart,
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Table
          if (pageList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No vehicles found.', style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 46,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                horizontalMargin: 16,
                columnSpacing: 22,
                headingRowColor: WidgetStateProperty.all(AppColors.tableHeader),
                headingTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Vehicle No.')),
                  DataColumn(label: Text('Company')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Brand')),
                  DataColumn(label: Text('Model')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (int i = 0; i < pageList.length; i++)
                    DataRow(
                      cells: [
                        DataCell(Text('${startIdx + i + 1}', style: const TextStyle(color: AppColors.muted))),
                        DataCell(
                          Text(
                            pageList[i].vehicleNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandNavy,
                            ),
                          ),
                        ),
                        DataCell(Text(pageList[i].company)),
                        DataCell(Text(pageList[i].type)),
                        DataCell(Text(pageList[i].brand)),
                        DataCell(Text(pageList[i].model)),
                        DataCell(StatusBadge(pageList[i].status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View Button (Eye Pill)
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryBlue),
                                tooltip: 'View details',
                                onPressed: () => _showVehicleDetailsDialog(context, pageList[i]),
                              ),
                              const SizedBox(width: 4),

                              // Edit Button (Blue Outlined Pill)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                onPressed: () => context.go('/vehicles/${pageList[i].id}/edit'),
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),

                              // Delete Button (Red Outlined Pill)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.red,
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  side: const BorderSide(color: Color(0xFFFECACA)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                onPressed: () => _delete(context, ref, pageList[i]),
                                icon: const Icon(Icons.delete_outline, size: 14),
                                label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 18),

          // Pagination Footer matching Image 1
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              final infoText = totalFiltered == 0
                  ? 'Showing 0 vehicles'
                  : 'Showing ${startIdx + 1} to $endIdx of $totalFiltered vehicles';

              if (isSmall) {
                return Column(
                  children: [
                    Text(infoText, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 8),
                    _buildPaginationControls(totalPages),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(infoText, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  _buildPaginationControls(totalPages),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prev Button
        InkWell(
          onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: _currentPage > 1 ? AppColors.charcoal : AppColors.muted,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Page Numbers
        for (int p = 1; p <= totalPages; p++)
          if (p == 1 || p == totalPages || (p >= _currentPage - 1 && p <= _currentPage + 1))
            InkWell(
              onTap: () => setState(() => _currentPage = p),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentPage == p ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _currentPage == p ? AppColors.primaryBlue : AppColors.border,
                  ),
                ),
                child: Text(
                  '$p',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _currentPage == p ? Colors.white : AppColors.charcoal,
                  ),
                ),
              ),
            ),
        const SizedBox(width: 6),

        // Next Button
        InkWell(
          onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: _currentPage < totalPages ? AppColors.charcoal : AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}
