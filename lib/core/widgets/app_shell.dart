import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../theme/app_colors.dart';
import 'app_asset_image.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _vehiclesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final email = ref.watch(authProvider).email ?? '';

    final sidebarWidget = _Sidebar(
      location: widget.location,
      vehiclesExpanded: _vehiclesExpanded,
      onToggleVehicles: () => setState(() => _vehiclesExpanded = !_vehiclesExpanded),
      isDrawer: isMobile,
      onLogout: () {
        if (isMobile) Navigator.of(context).maybePop();
        ref.read(authProvider.notifier).logout();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.softGray,
      drawer: isMobile
          ? Drawer(
              width: 270,
              backgroundColor: const Color(0xFF04142D),
              child: sidebarWidget,
            )
          : null,
      body: Row(
        children: [
          // Sidebar on Desktop / Tablet
          if (!isMobile) sidebarWidget,

          // Main Area
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  isMobile: isMobile,
                  email: email,
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 28,
                      vertical: isMobile ? 18 : 28,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.vehiclesExpanded,
    required this.onToggleVehicles,
    required this.isDrawer,
    required this.onLogout,
  });

  final String location;
  final bool vehiclesExpanded;
  final VoidCallback onToggleVehicles;
  final bool isDrawer;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isDashboard = location == '/dashboard' || location == '/';
    final isVehicles = location.startsWith('/vehicles');

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF03142D),
            Color(0xFF061E42),
            Color(0xFF092A5A),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Logo matching Image 1 & 3
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  AppAssetImage(
                    name: 'logo.png',
                    fallbackType: FallbackType.logo,
                    width: 36,
                    height: 36,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STARK GROUP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'VMS',
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    // Dashboard Button
                    _SidebarButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                      isSelected: isDashboard,
                      onTap: () {
                        if (isDrawer) Navigator.of(context).maybePop();
                        context.go('/dashboard');
                      },
                    ),
                    const SizedBox(height: 8),

                    // Vehicles Expandable Group
                    _SidebarExpandable(
                      icon: Icons.directions_car_outlined,
                      label: 'Vehicles',
                      isSelected: isVehicles,
                      isExpanded: vehiclesExpanded,
                      onToggle: onToggleVehicles,
                      onTapHeader: () {
                        if (isDrawer) Navigator.of(context).maybePop();
                        context.go('/vehicles');
                      },
                      children: [
                        _SidebarSubItem(
                          icon: Icons.add_circle_outline,
                          label: 'Register Vehicle',
                          isSelected: location == '/vehicles/new',
                          onTap: () {
                            if (isDrawer) Navigator.of(context).maybePop();
                            context.go('/vehicles/new');
                          },
                        ),
                        _SidebarSubItem(
                          icon: Icons.format_list_bulleted_rounded,
                          label: 'View Vehicle',
                          isSelected: location == '/vehicles',
                          onTap: () {
                            if (isDrawer) Navigator.of(context).maybePop();
                            context.go('/vehicles');
                          },
                        ),
                        _SidebarSubItem(
                          icon: Icons.edit_outlined,
                          label: 'Edit Vehicle',
                          isSelected: location.contains('/edit'),
                          onTap: () {
                            if (isDrawer) Navigator.of(context).maybePop();
                            context.go('/vehicles');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Click 'Edit' on any vehicle in the list to update its information."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                        _SidebarSubItem(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete Vehicle',
                          isSelected: false,
                          onTap: () {
                            if (isDrawer) Navigator.of(context).maybePop();
                            context.go('/vehicles');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Click 'Delete' on any vehicle in the list to remove it."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Admin Profile
                    _SidebarButton(
                      icon: Icons.person_outline_rounded,
                      label: 'Admin Profile',
                      isSelected: false,
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),

                    // Logout
                    _SidebarButton(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isSelected: false,
                      onTap: onLogout,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Skyline Backdrop matching Image 1 & 3
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 18),
              child: const Column(
                children: [
                  AppAssetImage(
                    name: 'skyline.png',
                    fallbackType: FallbackType.skyline,
                    height: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Drive · Manage · Grow',
                    style: TextStyle(
                      color: Color(0x8AFFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x401E60FF),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xB3FFFFFF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xB3FFFFFF),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarExpandable extends StatelessWidget {
  const _SidebarExpandable({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onToggle,
    required this.onTapHeader,
    required this.children,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTapHeader;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : const Color(0xB3FFFFFF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xB3FFFFFF),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0x8AFFFFFF),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 4),
            child: Column(children: children),
          ),
      ],
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  const _SidebarSubItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x241E60FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.cyanAccent : const Color(0x99FFFFFF),
                size: 16,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0x99FFFFFF),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isMobile,
    required this.email,
    required this.onLogout,
  });

  final bool isMobile;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Menu toggle
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.charcoal, size: 22),
              tooltip: 'Navigation Menu',
              onPressed: () {
                if (isMobile) {
                  Scaffold.of(ctx).openDrawer();
                }
              },
            ),
          ),

          // Right: AD Avatar + Admin Dropdown matching Image 1 & 3
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  email.isNotEmpty ? email : 'admin@starkgroup.com',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
