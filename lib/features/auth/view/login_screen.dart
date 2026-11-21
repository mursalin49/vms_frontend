import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1040),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F0F172A),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: isDesktop ? _buildDesktopSplit(auth) : _buildMobileStack(auth),
          ),
        ),
      ),
    );
  }

  /// Desktop 2-Column Split matching Image 2
  Widget _buildDesktopSplit(AuthState auth) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side: Blue Hero Branding
          Expanded(
            flex: 11,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF04193A),
                    Color(0xFF082B66),
                    Color(0xFF0B3B82),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Logo
                  const Row(
                    children: [
                      AppAssetImage(
                        name: 'logo.png',
                        fallbackType: FallbackType.logo,
                        width: 42,
                        height: 42,
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STARK GROUP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Drive · Manage · Grow',
                            style: TextStyle(
                              color: Color(0xB3FFFFFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Title & Subtitle
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Management\nSystem',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Smart Fleet Management for a Smarter Tomorrow',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Center Fleet Image with City Skyline (Bus, Car, Truck)
                  const Center(
                    child: FleetDarkBanner(
                      width: 440,
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3 Feature Badges at Bottom matching Image 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureBadge(Icons.verified_user_rounded, 'Secure\n& Reliable'),
                      Container(width: 1, height: 36, color: Colors.white24),
                      _buildFeatureBadge(Icons.insights_rounded, 'Real-time\nTracking'),
                      Container(width: 1, height: 36, color: Colors.white24),
                      _buildFeatureBadge(Icons.settings_suggest_rounded, 'Efficient\nManagement'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right Side: Login Form
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
              child: _buildForm(auth),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Stack Layout
  Widget _buildMobileStack(AuthState auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: _buildForm(auth),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E60FF).withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF38BDF8)),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthState auth) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Arch & Car Silhouette matching Image 2
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 36,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primaryBlue, width: 3),
                          left: BorderSide(color: AppColors.primaryBlue, width: 3),
                          right: BorderSide(color: AppColors.primaryBlue, width: 3),
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                    ),
                    const Positioned(
                      bottom: 0,
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.brandNavy,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'STARK GROUP VMS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.charcoal,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Vehicle Management System',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Admin Login Heading
          const Center(
            child: Text(
              'Admin Login',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Please sign in to your account',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Email Input with Mail Prefix
          CustomTextField(
            label: 'Email Address',
            controller: _email,
            hint: 'admin@starkgroup.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.muted),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofocus: true,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),

          // Password Input with Lock Prefix & Eye Suffix
          CustomTextField(
            label: 'Password',
            controller: _password,
            hint: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.muted),
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (v) => Validators.required(v, 'Password is required'),
            suffix: IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.muted,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),

          // Server Error Banner
          if (auth.error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Login Button with Arrow/Login Icon matching Image 2
          PrimaryButton(
            label: 'Login',
            icon: Icons.login_rounded,
            height: 48,
            expand: true,
            isLoading: auth.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 20),

          // Authorized administrators only footer
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: AppColors.muted),
              SizedBox(width: 6),
              Text(
                'Authorized administrators only.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
