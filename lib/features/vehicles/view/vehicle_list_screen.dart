import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import '../viewmodel/vehicle_list_viewmodel.dart';
import 'widgets/vehicle_stats_cards.dart';
import 'widgets/vehicle_table.dart';

class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  final _searchController = TextEditingController();
  VehicleStatus? _selectedStatus; // null means 'All'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Vehicle v) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete vehicle?',
      message: 'Vehicle ${v.vehicleNumber} will be permanently removed. This cannot be undone.',
    );
    if (!confirmed) return;
    try {
      await ref.read(vehicleListProvider.notifier).delete(v.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Vehicle deleted successfully')));
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListProvider);

    final registerButton = PrimaryButton(
      label: 'Register Vehicle',
      icon: Icons.add,
      onPressed: () => context.go('/vehicles/new'),
    );

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
        final totalCount = allVehicles.length;
        final activeCount = allVehicles.where((v) => v.status == VehicleStatus.active).length;
        final maintenanceCount = allVehicles.where((v) => v.status == VehicleStatus.maintenance).length;
        final inactiveCount = allVehicles.where((v) => v.status == VehicleStatus.inactive).length;

        // Apply search query and status filter
        final query = _searchController.text.trim().toLowerCase();
        final filteredList = allVehicles.where((v) {
          if (_selectedStatus != null && v.status != _selectedStatus) {
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            PageHeader(
              title: 'Vehicle List',
              subtitle: '$totalCount vehicles registered',
              action: registerButton,
            ),

            // 4 Stats Cards
            VehicleStatsCards(vehicles: allVehicles),
            const SizedBox(height: 28),

            // Search Bar & Filter Chips
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;

                final searchField = Container(
                  width: isNarrow ? double.infinity : 340,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
                    decoration: InputDecoration(
                      hintText: 'Search vehicle number...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.muted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                );

                final filterChips = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All · $totalCount',
                        selected: _selectedStatus == null,
                        onTap: () => setState(() => _selectedStatus = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Active · $activeCount',
                        selected: _selectedStatus == VehicleStatus.active,
                        onTap: () => setState(() => _selectedStatus = VehicleStatus.active),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Maintenance · $maintenanceCount',
                        selected: _selectedStatus == VehicleStatus.maintenance,
                        onTap: () => setState(() => _selectedStatus = VehicleStatus.maintenance),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'Inactive · $inactiveCount',
                        selected: _selectedStatus == VehicleStatus.inactive,
                        onTap: () => setState(() => _selectedStatus = VehicleStatus.inactive),
                      ),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      const SizedBox(height: 12),
                      filterChips,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    filterChips,
                    searchField,
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Table or Empty State
            if (filteredList.isEmpty)
              EmptyState(
                title: 'No vehicles found',
                message: allVehicles.isEmpty
                    ? 'Register your first vehicle to get started.'
                    : 'No vehicles match your search or filter.',
                action: allVehicles.isEmpty ? registerButton : null,
              )
            else ...[
              VehicleTable(
                vehicles: filteredList,
                onEdit: (v) => context.go('/vehicles/${v.id}/edit'),
                onDelete: (v) => _delete(context, ref, v),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Showing ${filteredList.length} of $totalCount results',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandNavy : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.brandNavy : AppColors.inputBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}
