import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/status_badge.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/domain/vehicle_status.dart';
import '../../vehicles/viewmodel/vehicle_list_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Vehicle v) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete vehicle?',
      message: 'Vehicle ${v.vehicleNumber} will be permanently removed.',
    );
    if (!confirmed) return;
    await ref.read(vehicleListProvider.notifier).delete(v.id!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleListProvider);

    return vehiclesAsync.when(
      loading: () => const LoadingSkeleton(),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.muted),
              const SizedBox(height: 12),
              Text('Could not load dashboard data: $e'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(vehicleListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (vehicles) {
        final total = vehicles.length;
        final active = vehicles.where((v) => v.status == VehicleStatus.active).length;
        final maintenance = vehicles.where((v) => v.status == VehicleStatus.maintenance).length;
        final inactive = vehicles.where((v) => v.status == VehicleStatus.inactive).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Welcome Banner
            _buildWelcomeBanner(context),
            const SizedBox(height: 20),

            // 2. 4 Stat Cards
            _buildStatCards(context, total, active, maintenance, inactive),
            const SizedBox(height: 24),

            // 3. Middle Section: Recent Vehicles (2/3) + Quick Overview (1/3)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 13,
                        child: _buildRecentVehiclesCard(context, ref, vehicles),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 7,
                        child: _buildQuickOverviewCard(total, active, maintenance, inactive),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildRecentVehiclesCard(context, ref, vehicles),
                    const SizedBox(height: 20),
                    _buildQuickOverviewCard(total, active, maintenance, inactive),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Bottom Quick Actions: Vehicle Management
            _buildQuickActions(context),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Welcome Banner with smooth ambient blend
  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF00235D),
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E1976D2),
            blurRadius: 28,
            offset: Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;
          final bannerHeight = isNarrow ? 150.0 : 160.0;
          final fleetWidth = isNarrow ? 360.0 : (constraints.maxWidth * 0.58).clamp(520.0, 660.0);

          return SizedBox(
            height: bannerHeight,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (!isNarrow)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: FleetBanner(
                      width: fleetWidth,
                      height: bannerHeight,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome Back,\nAdmin!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 36,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Here's your vehicle management overview.",
                              style: TextStyle(
                                color: Color(0xDEFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) SizedBox(width: fleetWidth * 0.65),
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

  /// 4 Stats Cards matching Image 3 (Seamless borderless design)
  Widget _buildStatCards(
    BuildContext context,
    int total,
    int active,
    int maintenance,
    int inactive,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isDesktop = w >= 900;
        const gap = 14.0;
        final cardWidth = isDesktop ? (w - (3 * gap)) / 4 : (w - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                icon: Icons.directions_car_filled_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF1E60FF),
                label: 'Total Vehicles',
                value: '$total',
                onTap: () => context.go('/vehicles'),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                icon: Icons.check_circle_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF10B981),
                label: 'Active Vehicles',
                value: '$active',
                onTap: () => context.go('/vehicles'),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                icon: Icons.build_rounded,
                iconBg: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFF59E0B),
                label: 'Maintenance Vehicles',
                value: '$maintenance',
                onTap: () => context.go('/vehicles'),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                icon: Icons.pause_circle_filled_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF64748B),
                label: 'Inactive Vehicles',
                value: '$inactive',
                onTap: () => context.go('/vehicles'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E3A8A),
            blurRadius: 24,
            offset: Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textSubtle),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  /// Recent Vehicle List Card (Seamless borderless surface)
  Widget _buildRecentVehiclesCard(BuildContext context, WidgetRef ref, List<Vehicle> vehicles) {
    final recent = vehicles.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E3A8A),
            blurRadius: 28,
            offset: Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Recent Vehicle List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.go('/vehicles'),
                label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No vehicles registered yet.', style: TextStyle(color: AppColors.muted))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                horizontalMargin: 12,
                columnSpacing: 20,
                headingTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Vehicle No.')),
                  DataColumn(label: Text('Company')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Brand')),
                  DataColumn(label: Text('Model')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  for (int i = 0; i < recent.length; i++)
                    DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(
                          Text(
                            recent[i].vehicleNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandNavy,
                            ),
                          ),
                        ),
                        DataCell(Text(recent[i].company)),
                        DataCell(Text(recent[i].type)),
                        DataCell(Text(recent[i].brand)),
                        DataCell(Text(recent[i].model)),
                        DataCell(StatusBadge(recent[i].status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primaryBlue),
                                tooltip: 'View',
                                onPressed: () => context.go('/vehicles'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryBlue),
                                tooltip: 'Edit',
                                onPressed: () => context.go('/vehicles/${recent[i].id}/edit'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                                tooltip: 'Delete',
                                onPressed: () => _delete(context, ref, recent[i]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Quick Overview Donut Chart Card (Seamless borderless surface)
  Widget _buildQuickOverviewCard(int total, int active, int maintenance, int inactive) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E3A8A),
            blurRadius: 28,
            offset: Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Quick Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut Chart + Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Donut Chart widget
              CustomPaint(
                size: const Size(120, 120),
                painter: _DonutChartPainter(
                  active: active,
                  maintenance: maintenance,
                  inactive: inactive,
                  total: total,
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendRow('Active', active, const Color(0xFF1E60FF)),
                  const SizedBox(height: 10),
                  _buildLegendRow('Maintenance', maintenance, const Color(0xFFF59E0B)),
                  const SizedBox(height: 10),
                  _buildLegendRow('Inactive', inactive, const Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wave Sparkline simulation
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              size: const Size(double.infinity, 44),
              painter: _SparklinePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        Text(
          '$count',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
      ],
    );
  }

  /// Bottom Quick Action Cards (Seamless borderless surface)
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E3A8A),
            blurRadius: 28,
            offset: Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_suggest_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    'Manage your fleet with ease.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isDesktop = w >= 900;
              const gap = 12.0;
              final cardW = isDesktop ? (w - (4 * gap)) / 5 : (w - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: cardW,
                    child: _buildActionTile(
                      icon: Icons.add_circle_outline,
                      title: 'Register Vehicle',
                      subtitle: 'Add a new vehicle',
                      isHighlighted: true,
                      onTap: () => context.go('/vehicles/new'),
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: _buildActionTile(
                      icon: Icons.directions_car_outlined,
                      title: 'View Vehicle',
                      subtitle: 'See all vehicles',
                      onTap: () => context.go('/vehicles'),
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: _buildActionTile(
                      icon: Icons.edit_note_rounded,
                      title: 'Edit Vehicle',
                      subtitle: 'Update vehicle info',
                      onTap: () => context.go('/vehicles'),
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: _buildActionTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Vehicle',
                      subtitle: 'Remove a vehicle',
                      onTap: () => context.go('/vehicles'),
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: _buildActionTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Duplicate Vehicle',
                      subtitle: 'Check for duplicate number',
                      onTap: () => context.go('/vehicles'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primaryBlue : AppColors.softGray,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isHighlighted
                ? const [
                    BoxShadow(
                      color: Color(0x401E60FF),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isHighlighted ? Colors.white : AppColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isHighlighted ? Colors.white : AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isHighlighted ? Colors.white70 : AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: isHighlighted ? Colors.white70 : AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.active,
    required this.maintenance,
    required this.inactive,
    required this.total,
  });

  final int active;
  final int maintenance;
  final int inactive;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = const Color(0xFFE2E8F0);
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final double activeAngle = (active / total) * 2 * math.pi;
    final double maintAngle = (maintenance / total) * 2 * math.pi;
    final double inactAngle = (inactive / total) * 2 * math.pi;

    double startAngle = -math.pi / 2;

    // Active (Blue)
    paint.color = const Color(0xFF1E60FF);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, activeAngle, false, paint);
    startAngle += activeAngle;

    // Maintenance (Amber)
    paint.color = const Color(0xFFF59E0B);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, maintAngle, false, paint);
    startAngle += maintAngle;

    // Inactive (Gray)
    paint.color = const Color(0xFF94A3B8);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, inactAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E60FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.25, size.height * 0.9,
      size.width * 0.5, size.height * 0.2,
      size.width * 0.75, size.height * 0.6,
    );
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.4);

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFF1E60FF);
    for (double x = 0; x <= size.width; x += size.width / 5) {
      canvas.drawCircle(Offset(x, size.height * 0.5), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
