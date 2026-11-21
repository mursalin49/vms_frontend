import 'package:flutter/material.dart';

/// App Logo widget with SVG + PNG support
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/logo.jpeg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildVectorLogo(size),
        ),
      ),
    );
  }

  static Widget _buildVectorLogo(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF1E60FF)],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: const Text(
        'S',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Unified Fleet Banner for Dashboard and Vehicle Management Top Banner
/// Uses building_bg.png and all_vihicales.png
class FleetBanner extends StatelessWidget {
  const FleetBanner({super.key, this.width, this.height = 110});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/building_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/fleet_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Image.asset(
            'assets/images/all_vihicales.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}

/// Dark Fleet Banner for Login Screen Left Panel
/// Uses transparent all_vihicales.png directly on top of the dark panel
class FleetDarkBanner extends StatelessWidget {
  const FleetDarkBanner({super.key, this.width, this.height = 160});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/all_vihicales.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/fleet_dark.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Car with Shield Illustration for the "Register New Vehicle" card
class CarShieldIllustration extends StatelessWidget {
  const CarShieldIllustration({super.key, this.width = 130, this.height = 110});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/car_shield.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.directions_car_filled_rounded,
        size: 64,
        color: Color(0xFF1E60FF),
      ),
    );
  }
}

/// Sidebar skyline graphic at bottom
class SidebarSkyline extends StatelessWidget {
  const SidebarSkyline({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'assets/images/skyline.png',
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => const SizedBox(),
      ),
    );
  }
}

/// General App Asset Image loader
class AppAssetImage extends StatelessWidget {
  const AppAssetImage({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackType = FallbackType.fleet,
  });

  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;
  final FallbackType fallbackType;

  @override
  Widget build(BuildContext context) {
    switch (fallbackType) {
      case FallbackType.logo:
        return AppLogo(size: width ?? 36);
      case FallbackType.fleet:
        return FleetBanner(width: width, height: height ?? 110);
      case FallbackType.carShield:
        return CarShieldIllustration(width: width ?? 130, height: height ?? 110);
      case FallbackType.skyline:
        return SidebarSkyline(height: height ?? 60);
    }
  }
}

enum FallbackType {
  logo,
  fleet,
  carShield,
  skyline,
}
