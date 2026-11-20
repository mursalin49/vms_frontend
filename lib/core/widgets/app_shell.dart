import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../theme/app_colors.dart';

/// Fully Responsive AppShell:
/// - Desktop (>= 1024px): Full 264px luxury navy sidebar
/// - Tablet (768px - 1023px): Compact 72px icon sidebar
/// - Mobile (< 768px): TopBar with Hamburger menu button & smooth Drawer navigation
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final email = ref.watch(authProvider).email ?? '';
    final registerActive = location.startsWith('/vehicles/new');

    final sidebarContent = _Sidebar(
      compact: isTablet && !isMobile,
      isDrawer: isMobile,
      registerActive: registerActive,
      email: email,
      onLogout: () {
        if (isMobile) Navigator.of(context).maybePop();
        ref.read(authProvider.notifier).logout();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.softGray,
      drawer: isMobile
          ? Drawer(
              width: 280,
              backgroundColor: AppColors.brandNavy,
              child: sidebarContent,
            )
          : null,
      body: Row(
        children: [
          // Sidebar on Tablet & Desktop only
          if (!isMobile) sidebarContent,

          // Main Content Area
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
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 20 : 32,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: child,
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
    required this.compact,
    required this.isDrawer,
    required this.registerActive,
    required this.email,
    required this.onLogout,
  });

  final bool compact;
  final bool isDrawer;
  final bool registerActive;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final double width = isDrawer
        ? 280
        : compact
            ? 72
            : 264;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandNavy,
            AppColors.deepNavy,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 20,
        vertical: isDrawer ? 40 : 28,
      ),
      child: SafeArea(
        top: isDrawer,
        bottom: isDrawer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo & Brand Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 6),
              child: Row(
                mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Text(
                      'V',
                      style: TextStyle(
                        color: AppColors.brandNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'VMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Nav Items
            _NavItem(
              icon: Icons.directions_car_outlined,
              label: 'Vehicles',
              compact: compact,
              selected: !registerActive,
              onTap: () {
                if (isDrawer) Navigator.of(context).maybePop();
                context.go('/vehicles');
              },
            ),
            const SizedBox(height: 6),
            _NavItem(
              icon: Icons.add_circle_outline,
              label: 'Register Vehicle',
              compact: compact,
              selected: registerActive,
              onTap: () {
                if (isDrawer) Navigator.of(context).maybePop();
                context.go('/vehicles/new');
              },
            ),

            const Spacer(),

            // Bottom User Profile Box
            Container(
              padding: EdgeInsets.only(top: 16, left: compact ? 0 : 6, right: compact ? 0 : 6),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x24FFFFFF))),
              ),
              child: Row(
                mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  // Gold Avatar
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.goldAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: AppColors.brandNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email.isNotEmpty ? email : 'Stark Group',
                            style: const TextStyle(
                              color: Color(0xA6FFFFFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout, size: 18, color: Colors.white70),
                      onPressed: onLogout,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0x1FFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? const Border(
                    left: BorderSide(color: AppColors.goldAccent, width: 3.5),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : const Color(0xC7FFFFFF),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xC7FFFFFF),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
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
      height: isMobile ? 60 : 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Drawer button on Mobile, or Fleet tag on Tablet/Desktop
          if (isMobile)
            Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.brandNavy, size: 24),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    tooltip: 'Open navigation',
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'VMS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandNavy,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.deepBlue),
                  SizedBox(width: 6),
                  Text(
                    'Stark Fleet Workspace',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ],
              ),
            ),

          // User Profile Avatar on Right
          Row(
            children: [
              Container(
                width: isMobile ? 32 : 38,
                height: isMobile ? 32 : 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.corporateBlue, AppColors.deepBlue],
                  ),
                ),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ),
              if (isMobile) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.logout, size: 18, color: AppColors.muted),
                  tooltip: 'Logout',
                  onPressed: onLogout,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
