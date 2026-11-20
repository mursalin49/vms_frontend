import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../theme/app_colors.dart';

/// Redesigned AppShell: Luxury Navy Sidebar + Clean TopBar + Responsive Content Area
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = MediaQuery.of(context).size.width < 900;
    final email = ref.watch(authProvider).email ?? '';
    final registerActive = location.startsWith('/vehicles/new');

    return Scaffold(
      backgroundColor: AppColors.softGray,
      body: Row(
        children: [
          _Sidebar(
            compact: compact,
            registerActive: registerActive,
            email: email,
            onLogout: () => ref.read(authProvider.notifier).logout(),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  email: email,
                  compact: compact,
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 20 : 40),
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
    required this.registerActive,
    required this.email,
    required this.onLogout,
  });

  final bool compact;
  final bool registerActive;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 76 : 264,
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
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 20, vertical: 28),
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
            onTap: () => context.go('/vehicles'),
          ),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.add_circle_outline,
            label: 'Register Vehicle',
            compact: compact,
            selected: registerActive,
            onTap: () => context.go('/vehicles/new'),
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
    required this.email,
    required this.compact,
    required this.onLogout,
  });

  final String email;
  final bool compact;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 40),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Fleet branding tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            ],
          ),

          // User Profile Avatar on Right
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.corporateBlue, AppColors.deepBlue],
                  ),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
